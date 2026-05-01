abstract final class AppConstants {
  static const String appName = 'SASO Willen';
  static const String version = '0.1.0';

  static const String serverUrlKey = 'server_url';
  static const String apiModeKey = 'api_mode';
  static const String sessionCookieKey = 'session_cookie';
  static const String jwtTokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String deviceIdKey = 'device_id';
  static const String offlineModeKey = 'offline_mode';
  static const String authProviderKey = 'auth_provider_cache';

  static const Duration httpTimeout = Duration(seconds: 30);
  static const Duration cacheMaxAge = Duration(hours: 24);
}

abstract final class FeatureFlags {
  static const String restApiV1 = 'ff_rest_api_v1';
  static const String pushFcm = 'ff_push_fcm';
  static const String pushSns = 'ff_push_sns';
  static const String authOidc = 'ff_auth_oidc';
  static const String authFirebase = 'ff_auth_firebase';
  static const String offlineMode = 'ff_offline_mode';
  static const String barcodeScanner = 'ff_barcode_scanner';
  static const String labelPrint = 'ff_label_print';

  static const Map<String, bool> defaults = {
    restApiV1: false,
    pushFcm: true,
    pushSns: false,
    authOidc: true,
    authFirebase: true,
    offlineMode: true,
    barcodeScanner: true,
    labelPrint: false,
  };
}
