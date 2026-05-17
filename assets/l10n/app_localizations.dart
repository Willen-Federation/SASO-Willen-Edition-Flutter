import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In ja, this message translates to:
  /// **'SASO Willen'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get home;

  /// No description provided for @items.
  ///
  /// In ja, this message translates to:
  /// **'アイテム'**
  String get items;

  /// No description provided for @categories.
  ///
  /// In ja, this message translates to:
  /// **'カテゴリ'**
  String get categories;

  /// No description provided for @scanner.
  ///
  /// In ja, this message translates to:
  /// **'スキャン'**
  String get scanner;

  /// No description provided for @shelf.
  ///
  /// In ja, this message translates to:
  /// **'棚'**
  String get shelf;

  /// No description provided for @settings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In ja, this message translates to:
  /// **'検索'**
  String get search;

  /// No description provided for @searchItems.
  ///
  /// In ja, this message translates to:
  /// **'アイテムを検索'**
  String get searchItems;

  /// No description provided for @searchHint.
  ///
  /// In ja, this message translates to:
  /// **'アイテムIDまたは名前を入力'**
  String get searchHint;

  /// No description provided for @itemId.
  ///
  /// In ja, this message translates to:
  /// **'アイテムID'**
  String get itemId;

  /// No description provided for @itemName.
  ///
  /// In ja, this message translates to:
  /// **'アイテム名'**
  String get itemName;

  /// No description provided for @itemFeatures.
  ///
  /// In ja, this message translates to:
  /// **'バリエーション'**
  String get itemFeatures;

  /// No description provided for @itemRegisteredAt.
  ///
  /// In ja, this message translates to:
  /// **'登録日'**
  String get itemRegisteredAt;

  /// No description provided for @categoryName.
  ///
  /// In ja, this message translates to:
  /// **'カテゴリ名'**
  String get categoryName;

  /// No description provided for @noChildren.
  ///
  /// In ja, this message translates to:
  /// **'サブカテゴリなし'**
  String get noChildren;

  /// No description provided for @shelfId.
  ///
  /// In ja, this message translates to:
  /// **'棚ID'**
  String get shelfId;

  /// No description provided for @shelfItems.
  ///
  /// In ja, this message translates to:
  /// **'棚のアイテム'**
  String get shelfItems;

  /// No description provided for @serverUrl.
  ///
  /// In ja, this message translates to:
  /// **'サーバーURL'**
  String get serverUrl;

  /// No description provided for @serverUrlHint.
  ///
  /// In ja, this message translates to:
  /// **'例: https://saso.example.com'**
  String get serverUrlHint;

  /// No description provided for @apiMode.
  ///
  /// In ja, this message translates to:
  /// **'APIモード'**
  String get apiMode;

  /// No description provided for @apiModeMock.
  ///
  /// In ja, this message translates to:
  /// **'モック（サーバー不要）'**
  String get apiModeMock;

  /// No description provided for @apiModeLegacy.
  ///
  /// In ja, this message translates to:
  /// **'レガシー（互換モード）'**
  String get apiModeLegacy;

  /// No description provided for @apiModeRest.
  ///
  /// In ja, this message translates to:
  /// **'REST v1'**
  String get apiModeRest;

  /// No description provided for @testConnection.
  ///
  /// In ja, this message translates to:
  /// **'接続テスト'**
  String get testConnection;

  /// No description provided for @connectionSuccess.
  ///
  /// In ja, this message translates to:
  /// **'接続成功'**
  String get connectionSuccess;

  /// No description provided for @connectionFailed.
  ///
  /// In ja, this message translates to:
  /// **'接続失敗'**
  String get connectionFailed;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @scanBarcode.
  ///
  /// In ja, this message translates to:
  /// **'バーコードをスキャン'**
  String get scanBarcode;

  /// No description provided for @scanResult.
  ///
  /// In ja, this message translates to:
  /// **'スキャン結果'**
  String get scanResult;

  /// No description provided for @loading.
  ///
  /// In ja, this message translates to:
  /// **'読み込み中...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ja, this message translates to:
  /// **'データがありません'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In ja, this message translates to:
  /// **'エラー'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In ja, this message translates to:
  /// **'再試行'**
  String get retry;

  /// No description provided for @login.
  ///
  /// In ja, this message translates to:
  /// **'ログイン'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get logout;

  /// No description provided for @username.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー名'**
  String get username;

  /// No description provided for @password.
  ///
  /// In ja, this message translates to:
  /// **'パスワード'**
  String get password;

  /// No description provided for @loginFailed.
  ///
  /// In ja, this message translates to:
  /// **'ログインに失敗しました'**
  String get loginFailed;

  /// No description provided for @featureFlags.
  ///
  /// In ja, this message translates to:
  /// **'機能フラグ'**
  String get featureFlags;

  /// No description provided for @flagRestApi.
  ///
  /// In ja, this message translates to:
  /// **'REST API v1'**
  String get flagRestApi;

  /// No description provided for @flagPushFcm.
  ///
  /// In ja, this message translates to:
  /// **'FCMプッシュ通知'**
  String get flagPushFcm;

  /// No description provided for @flagPushSns.
  ///
  /// In ja, this message translates to:
  /// **'Amazon SNSプッシュ通知'**
  String get flagPushSns;

  /// No description provided for @flagAuthOidc.
  ///
  /// In ja, this message translates to:
  /// **'OIDC認証'**
  String get flagAuthOidc;

  /// No description provided for @flagAuthFirebase.
  ///
  /// In ja, this message translates to:
  /// **'Firebase認証'**
  String get flagAuthFirebase;

  /// No description provided for @flagOfflineMode.
  ///
  /// In ja, this message translates to:
  /// **'オフラインモード'**
  String get flagOfflineMode;

  /// No description provided for @flagBarcodeScanner.
  ///
  /// In ja, this message translates to:
  /// **'バーコードスキャン'**
  String get flagBarcodeScanner;

  /// No description provided for @flagLabelPrint.
  ///
  /// In ja, this message translates to:
  /// **'ラベル印刷'**
  String get flagLabelPrint;

  /// No description provided for @samlProviderNotActive.
  ///
  /// In ja, this message translates to:
  /// **'SAMLプロバイダーが有効ではありません'**
  String get samlProviderNotActive;

  /// No description provided for @pairingFailed.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング失敗'**
  String get pairingFailed;

  /// No description provided for @pairingFailedWithStatus.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング失敗 (HTTP {status})'**
  String pairingFailedWithStatus(int status);

  /// No description provided for @pairingNetworkError.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング通信エラー: {details}'**
  String pairingNetworkError(String details);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
