/// Server response from `GET /api/v1/mobile/discovery`.
///
/// Used by the registration flow to decide whether to skip the provider
/// chooser (when the server has marked one IdP as default) and to compose
/// the in-app browser URL.
class MobileDiscoveryModel {
  const MobileDiscoveryModel({
    required this.serverName,
    required this.version,
    required this.mobileSetupUrl,
    required this.authStrategy,
    required this.providers,
  });

  final String serverName;
  final String version;
  final String mobileSetupUrl;
  final String authStrategy; // default-only | user-choice | local-only
  final List<MobileDiscoveryProvider> providers;

  factory MobileDiscoveryModel.fromJson(Map<String, dynamic> json) {
    return MobileDiscoveryModel(
      serverName: json['serverName'] as String? ?? '',
      version: json['version'] as String? ?? '',
      mobileSetupUrl: json['mobileSetupUrl'] as String? ?? '',
      authStrategy: json['authStrategy'] as String? ?? 'local-only',
      providers: ((json['providers'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MobileDiscoveryProvider.fromJson)
          .toList(growable: false),
    );
  }
}

class MobileDiscoveryProvider {
  const MobileDiscoveryProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    required this.enabled,
  });

  final int id;
  final String name;
  final String type; // local | oidc | saml
  final bool isDefault;
  final bool enabled;

  factory MobileDiscoveryProvider.fromJson(Map<String, dynamic> json) {
    return MobileDiscoveryProvider(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'oidc',
      isDefault: json['isDefault'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? false,
    );
  }
}
