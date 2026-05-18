// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SASO Willen';

  @override
  String get home => 'Home';

  @override
  String get items => 'Items';

  @override
  String get categories => 'Categories';

  @override
  String get scanner => 'Scanner';

  @override
  String get shelf => 'Shelf';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get searchItems => 'Search Items';

  @override
  String get searchHint => 'Enter item ID or name';

  @override
  String get itemId => 'Item ID';

  @override
  String get itemName => 'Item Name';

  @override
  String get itemFeatures => 'Variations';

  @override
  String get itemRegisteredAt => 'Registered At';

  @override
  String get itemStatus => 'Status';

  @override
  String get itemStatusActive => 'Active';

  @override
  String get itemStatusArchived => 'Archived';

  @override
  String get itemStatusDiscontinued => 'Discontinued';

  @override
  String get itemStatusPending => 'Pending';

  @override
  String get itemStatusInStorage => 'In storage';

  @override
  String get itemStatusInUse => 'In use';

  @override
  String get itemStatusForSale => 'For sale';

  @override
  String get itemStatusReserved => 'Reserved';

  @override
  String get itemStatusShipped => 'Shipped';

  @override
  String get itemStatusChange => 'Change status';

  @override
  String get itemStatusUpdated => 'Status updated';

  @override
  String itemStatusUpdateFailed(String detail) {
    return 'Failed to update status: $detail';
  }

  @override
  String get categoryName => 'Category Name';

  @override
  String get noChildren => 'No subcategories';

  @override
  String get shelfId => 'Shelf ID';

  @override
  String get shelfItems => 'Items on Shelf';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlHint => 'e.g. https://saso.example.com';

  @override
  String get apiMode => 'API Mode';

  @override
  String get apiModeMock => 'Mock (no server needed)';

  @override
  String get apiModeLegacy => 'Legacy (compatibility mode)';

  @override
  String get apiModeRest => 'REST v1';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get connectionSuccess => 'Connection successful';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get scanResult => 'Scan Result';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get loginScreenTitle => 'Login';

  @override
  String get loginWithBrowser => 'Login with Browser';

  @override
  String get loginWithSso => 'Login with SSO';

  @override
  String get loginWithQr => 'Pair via QR code';

  @override
  String get loginStandard => 'Standard login';

  @override
  String get samlLoginTitle => 'SSO Login';

  @override
  String get samlLoginCancelled => 'SAML login was cancelled';

  @override
  String samlLoginInvalidUrl(String detail) {
    return 'Invalid SSO login URL: $detail';
  }

  @override
  String get qrPairingTitle => 'QR Pairing';

  @override
  String get qrPairingInProgress => 'Pairing...';

  @override
  String qrPairingFailed(int statusCode) {
    return 'Pairing failed (HTTP $statusCode)';
  }

  @override
  String get qrPairingUrlMismatch =>
      'QR server URL does not match the configured URL';

  @override
  String get qrPairingUrlInvalid => 'Server URL must use HTTPS';

  @override
  String authLegacyHttpsRequired(String detail) {
    return 'Server URL must use HTTPS: $detail';
  }

  @override
  String get authSessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String authNetworkError(String detail) {
    return 'Network error: $detail';
  }

  @override
  String get pairedDevicesSection => 'Paired devices';

  @override
  String get manageDevicesOnWeb => 'Manage paired devices on web';

  @override
  String manageDevicesOnWebSubtitle(String url) {
    return 'Opens $url in your browser to revoke or rename this device.';
  }

  @override
  String openWebPortalFailed(String detail) {
    return 'Could not open the web portal: $detail';
  }

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get offlineBadge => 'Offline';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get offlineModeDescription =>
      'When ON, writes are queued locally instead of being sent to the server.';

  @override
  String get downloadAllData => 'Download all data';

  @override
  String get sendPendingData => 'Send pending data';

  @override
  String get featureNotReady => 'This feature is coming soon';

  @override
  String get settingsHeader => 'Server settings';

  @override
  String get scopeInsufficientTitle => 'This device cannot do that';

  @override
  String scopeInsufficientDetail(String scope) {
    return 'Your paired device is missing the $scope permission. Re-pair from /mypage to get the right scopes.';
  }

  @override
  String get scopeInsufficientCta => 'Re-pair device';

  @override
  String get qrPairingSuccessTitle => 'Device paired';

  @override
  String qrPairingSuccessBody(String server) {
    return '$server is now linked to this device.';
  }

  @override
  String get qrPairingContinue => 'Continue';

  @override
  String get qrPairingNoServerUrl =>
      'No server URL is configured. Set it in Settings first.';

  @override
  String qrPairingServerInvalid(String detail) {
    return 'The configured server URL is invalid: $detail';
  }

  @override
  String get qrPairingQrUrlInvalid =>
      'The server URL in the QR code is not valid.';

  @override
  String get qrPairingUrlMismatchExplain =>
      'The QR code\'s server URL doesn\'t match what\'s configured. Pairing was cancelled for your safety.';

  @override
  String get qrPairingInstruction =>
      'Scan the QR code shown on the SASO admin screen.';

  @override
  String get connectionTestUrlMissing => 'Server URL is empty.';

  @override
  String get connectionTestUrlInvalid => 'Server URL is malformed.';

  @override
  String connectionTestHttpError(int statusCode) {
    return 'Server returned HTTP $statusCode.';
  }

  @override
  String connectionTestFailure(String detail) {
    return 'Connection failed: $detail';
  }

  @override
  String get featureFlags => 'Feature Flags';

  @override
  String get flagRestApi => 'REST API v1';

  @override
  String get flagPushFcm => 'FCM Push Notifications';

  @override
  String get flagPushSns => 'Amazon SNS Push Notifications';

  @override
  String get flagAuthOidc => 'OIDC Authentication';

  @override
  String get flagAuthFirebase => 'Firebase Authentication';

  @override
  String get flagOfflineMode => 'Offline Mode';

  @override
  String get flagBarcodeScanner => 'Barcode Scanner';

  @override
  String get flagLabelPrint => 'Label Printing';
}
