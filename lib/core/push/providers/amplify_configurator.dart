import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_push_notifications_pinpoint/amplify_push_notifications_pinpoint.dart';

import '../../../amplifyconfiguration.dart';
import '../../auth/auth_provider_config.dart';
import '../../feature_flags/feature_flag_service.dart';
import '../../logging/app_logger.dart';

class AmplifyConfigurator {
  static bool _configured = false;

  /// Configures Amplify using the discovery document.
  static Future<void> configure(ServerAuthDiscovery discovery) async {
    if (_configured || Amplify.isConfigured) {
      _configured = true;
      return;
    }

    AuthProviderSummary? cognitoProvider;
    for (final p in discovery.providers) {
      if (p.enabled && p.type == AuthProviderType.cognito) {
        cognitoProvider = p;
        break;
      }
    }

    final userPoolId = cognitoProvider?.config['userPoolId'];
    final clientId = cognitoProvider?.config['clientId'];
    final region = cognitoProvider?.config['region'] ?? 'ap-northeast-1';
    final hostedUiDomain = cognitoProvider?.config['hostedUiDomain'];

    await configureWithDetails(
      userPoolId: userPoolId,
      clientId: clientId,
      region: region,
      hostedUiDomain: hostedUiDomain,
    );
  }

  /// Configures Amplify with specific Cognito details (if provided) and/or Pinpoint.
  static Future<void> configureWithDetails({
    String? userPoolId,
    String? clientId,
    String? region,
    String? hostedUiDomain,
  }) async {
    if (_configured || Amplify.isConfigured) {
      _configured = true;
      return;
    }

    try {
      final flags = FeatureFlagService.instance;
      final useSns = flags.getBool(FeatureFlags.pushSns);
      final hasCognito = userPoolId != null && userPoolId.isNotEmpty && clientId != null && clientId.isNotEmpty;

      if (!useSns && !hasCognito) {
        return;
      }

      if (useSns) {
        await Amplify.addPlugin(AmplifyPushNotificationsPinpoint());
      }

      if (hasCognito) {
        await Amplify.addPlugin(AmplifyAuthCognito());
      }

      // Build config map
      final Map<String, dynamic> configMap = {
        'UserAgent': 'aws-amplify-cli/2.0',
        'Version': '1.0',
      };

      if (useSns) {
        try {
          final Map<String, dynamic> snsConfig = jsonDecode(amplifyconfig) as Map<String, dynamic>;
          if (snsConfig.containsKey('notifications')) {
            configMap['notifications'] = snsConfig['notifications'];
          }
        } catch (e, stack) {
          AppLogger.error('AmplifyConfig', 'Failed to parse static amplifyconfig', e, stack);
        }
      }

      if (hasCognito) {
        final cognitoPlugin = <String, dynamic>{
          'UserAgent': 'aws-amplify-cli/2.0',
          'Version': '0.1.0',
          'CognitoUserPool': {
            'Default': {
              'PoolId': userPoolId,
              'AppClientId': clientId,
              'Region': region ?? 'ap-northeast-1',
            },
          },
          'Auth': {
            'Default': {
              'authenticationFlowType': 'USER_SRP_AUTH',
              if (hostedUiDomain != null && hostedUiDomain.isNotEmpty)
                'OAuth': {
                  'WebDomain': hostedUiDomain,
                  'AppClientId': clientId,
                  'SignInRedirectURI': 'jp.willen.saso://callback',
                  'SignOutRedirectURI': 'jp.willen.saso://logout',
                  'Scopes': ['openid', 'profile', 'email'],
                },
            },
          },
        };

        configMap['auth'] = {
          'plugins': {
            'awsCognitoAuthPlugin': cognitoPlugin,
          }
        };
      }

      await Amplify.configure(jsonEncode(configMap));
      _configured = true;
      AppLogger.info('AmplifyConfig', 'Amplify configured successfully');
    } catch (e, stack) {
      AppLogger.error('AmplifyConfig', 'Amplify configuration failed', e, stack);
      // Suppress crash on configuration failure (e.g. stub/invalid values)
    }
  }
}
