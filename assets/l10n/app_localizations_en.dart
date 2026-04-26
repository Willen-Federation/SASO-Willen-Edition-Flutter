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
