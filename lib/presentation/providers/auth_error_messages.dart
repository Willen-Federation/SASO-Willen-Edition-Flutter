import 'package:flutter/widgets.dart';

// ignore: avoid_relative_lib_imports
import '../../../assets/l10n/app_localizations.dart';
import 'auth_state_provider.dart';

/// Resolves an [AuthFailure] returned by [AuthStateNotifier] into a string
/// suitable for display, picking the localised template that matches the
/// machine-readable error code. The free-form `message` field is treated as
/// an opaque diagnostic and only surfaced for codes that template it in.
String localizedAuthErrorMessage(BuildContext context, String? code, String fallback) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return fallback;

  switch (code) {
    case AuthErrorCodes.wrongProvider:
      return l10n.samlProviderNotActive;
    case AuthErrorCodes.pairingHttpError:
      // The free-form message holds "HTTP <code>"; parse out the code.
      final status = int.tryParse(
        RegExp(r'\d+').firstMatch(fallback)?.group(0) ?? '',
      );
      return status != null
          ? l10n.pairingFailedWithStatus(status)
          : l10n.pairingFailed;
    case AuthErrorCodes.pairingNetworkError:
      return l10n.pairingNetworkError(fallback);
    default:
      return fallback;
  }
}
