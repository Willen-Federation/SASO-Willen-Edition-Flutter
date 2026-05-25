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
  /// **'SASO-WILLEN'**
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

  /// No description provided for @itemStatus.
  ///
  /// In ja, this message translates to:
  /// **'ステータス'**
  String get itemStatus;

  /// No description provided for @itemStatusActive.
  ///
  /// In ja, this message translates to:
  /// **'アクティブ'**
  String get itemStatusActive;

  /// No description provided for @itemStatusArchived.
  ///
  /// In ja, this message translates to:
  /// **'アーカイブ'**
  String get itemStatusArchived;

  /// No description provided for @itemStatusDiscontinued.
  ///
  /// In ja, this message translates to:
  /// **'廃盤'**
  String get itemStatusDiscontinued;

  /// No description provided for @itemStatusPending.
  ///
  /// In ja, this message translates to:
  /// **'保留中'**
  String get itemStatusPending;

  /// No description provided for @itemStatusInStorage.
  ///
  /// In ja, this message translates to:
  /// **'保管中'**
  String get itemStatusInStorage;

  /// No description provided for @itemStatusInUse.
  ///
  /// In ja, this message translates to:
  /// **'利用中'**
  String get itemStatusInUse;

  /// No description provided for @itemStatusForSale.
  ///
  /// In ja, this message translates to:
  /// **'販売中'**
  String get itemStatusForSale;

  /// No description provided for @itemStatusReserved.
  ///
  /// In ja, this message translates to:
  /// **'仮押さえ'**
  String get itemStatusReserved;

  /// No description provided for @itemStatusShipped.
  ///
  /// In ja, this message translates to:
  /// **'発送済み'**
  String get itemStatusShipped;

  /// No description provided for @itemStatusChange.
  ///
  /// In ja, this message translates to:
  /// **'ステータス変更'**
  String get itemStatusChange;

  /// No description provided for @itemStatusUpdated.
  ///
  /// In ja, this message translates to:
  /// **'ステータスを更新しました'**
  String get itemStatusUpdated;

  /// SnackBar shown when an item status PATCH fails. Placeholder is the underlying error's toString().
  ///
  /// In ja, this message translates to:
  /// **'ステータス変更に失敗しました: {detail}'**
  String itemStatusUpdateFailed(String detail);

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

  /// No description provided for @apiModeMockDescription.
  ///
  /// In ja, this message translates to:
  /// **'ローカル開発用のインメモリデータ。ネットワーク通信を行いません。'**
  String get apiModeMockDescription;

  /// No description provided for @apiModeRest.
  ///
  /// In ja, this message translates to:
  /// **'REST v1'**
  String get apiModeRest;

  /// No description provided for @apiModeRestDescription.
  ///
  /// In ja, this message translates to:
  /// **'JWT ベースの REST API。本番環境ではこちらを推奨します。'**
  String get apiModeRestDescription;

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

  /// AppBar title for the barcode scanner in search mode (navigates to matching item/shelf/feature). Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'バーコードスキャン'**
  String get barcodeScannerTitleSearch;

  /// AppBar title for the barcode scanner in register mode (returns scanned code to caller). Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'バーコード読み取り'**
  String get barcodeScannerTitleRegister;

  /// AppBar title for the barcode scanner in inventory mode (navigates to inventory adjustment). Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'入出庫スキャン'**
  String get barcodeScannerTitleInventory;

  /// Hint text shown over camera preview in search mode. Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'バーコードをフレーム内に合わせてください'**
  String get barcodeScannerHintSearch;

  /// Hint text shown over camera preview in register mode. Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'読み取るバーコードをフレーム内に合わせてください'**
  String get barcodeScannerHintRegister;

  /// Hint text shown over camera preview in inventory mode. Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'棚または商品のバーコードをスキャンしてください'**
  String get barcodeScannerHintInventory;

  /// Tooltip for the torch toggle button in the scanner AppBar. Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'フラッシュ'**
  String get barcodeScannerTorchTooltip;

  /// Tooltip for the camera switch button in the scanner AppBar. Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'カメラ切替'**
  String get barcodeScannerSwitchCameraTooltip;

  /// Dialog title when scanned code does not match any item/shelf/feature/ISBN format. Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'コードを認識できません'**
  String get barcodeScannerUnrecognizedTitle;

  /// Dialog body offering to register a new item from an unrecognized scan. Placeholder is the raw scanned code. Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'{code}\n\nこのコードで新しいアイテムを登録しますか？'**
  String barcodeScannerUnrecognizedMessage(String code);

  /// Confirmation button label that navigates to item registration with the scanned code. Issue #135.
  ///
  /// In ja, this message translates to:
  /// **'アイテム登録'**
  String get barcodeScannerRegisterItem;

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

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In ja, this message translates to:
  /// **'ログアウトしますか？認証情報は削除されます。'**
  String get logoutConfirmMessage;

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

  /// No description provided for @loginScreenTitle.
  ///
  /// In ja, this message translates to:
  /// **'ログイン'**
  String get loginScreenTitle;

  /// No description provided for @loginWithBrowser.
  ///
  /// In ja, this message translates to:
  /// **'ブラウザでログイン'**
  String get loginWithBrowser;

  /// No description provided for @loginWithSso.
  ///
  /// In ja, this message translates to:
  /// **'SSOでログイン'**
  String get loginWithSso;

  /// No description provided for @loginWithQr.
  ///
  /// In ja, this message translates to:
  /// **'QRコードでペアリング'**
  String get loginWithQr;

  /// No description provided for @loginStandard.
  ///
  /// In ja, this message translates to:
  /// **'標準ログイン'**
  String get loginStandard;

  /// No description provided for @samlLoginTitle.
  ///
  /// In ja, this message translates to:
  /// **'SSOログイン'**
  String get samlLoginTitle;

  /// No description provided for @samlLoginCancelled.
  ///
  /// In ja, this message translates to:
  /// **'SAMLログインがキャンセルされました'**
  String get samlLoginCancelled;

  /// Shown in the SAML WebView when the IdP URL fails UrlValidator.ensureHttpsOrLoopback. The placeholder is the validator's reason string.
  ///
  /// In ja, this message translates to:
  /// **'SSOログインURLが無効です: {detail}'**
  String samlLoginInvalidUrl(String detail);

  /// No description provided for @qrPairingTitle.
  ///
  /// In ja, this message translates to:
  /// **'QRペアリング'**
  String get qrPairingTitle;

  /// No description provided for @qrPairingInProgress.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング中...'**
  String get qrPairingInProgress;

  /// Shown after the /api/v1/mobile/connect endpoint rejects the pairing token. Placeholder is the HTTP status code.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング失敗 (HTTP {statusCode})'**
  String qrPairingFailed(int statusCode);

  /// No description provided for @qrPairingUrlMismatch.
  ///
  /// In ja, this message translates to:
  /// **'QRコードのサーバーURLが設定と一致しません'**
  String get qrPairingUrlMismatch;

  /// No description provided for @qrPairingUrlInvalid.
  ///
  /// In ja, this message translates to:
  /// **'サーバーURLはHTTPSである必要があります'**
  String get qrPairingUrlInvalid;

  /// Legacy login HTTPS guard (#36). Surfaced when the user typed an http:// or invalid URL.
  ///
  /// In ja, this message translates to:
  /// **'サーバーURLはHTTPSである必要があります: {detail}'**
  String authLegacyHttpsRequired(String detail);

  /// No description provided for @authSessionExpired.
  ///
  /// In ja, this message translates to:
  /// **'セッションの有効期限が切れました。再度ログインしてください。'**
  String get authSessionExpired;

  /// Surfaced when the HTTP layer rejects the call (timeout / connection refused). Placeholder is the underlying exception's toString().
  ///
  /// In ja, this message translates to:
  /// **'ネットワークエラー: {detail}'**
  String authNetworkError(String detail);

  /// No description provided for @pairedDevicesSection.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング済み端末'**
  String get pairedDevicesSection;

  /// No description provided for @manageDevicesOnWeb.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング端末をブラウザで管理'**
  String get manageDevicesOnWeb;

  /// No description provided for @manageDevicesOnWebSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'{url} をブラウザで開いて、端末の取り消しや名前変更を行います。'**
  String manageDevicesOnWebSubtitle(String url);

  /// No description provided for @openWebPortalFailed.
  ///
  /// In ja, this message translates to:
  /// **'ブラウザを開けませんでした: {detail}'**
  String openWebPortalFailed(String detail);

  /// No description provided for @settingsSaved.
  ///
  /// In ja, this message translates to:
  /// **'設定を保存しました'**
  String get settingsSaved;

  /// No description provided for @offlineBadge.
  ///
  /// In ja, this message translates to:
  /// **'オフライン'**
  String get offlineBadge;

  /// No description provided for @offlineMode.
  ///
  /// In ja, this message translates to:
  /// **'オフラインモード'**
  String get offlineMode;

  /// No description provided for @offlineModeDescription.
  ///
  /// In ja, this message translates to:
  /// **'ONにすると書き込みをキューに蓄積し、サーバーへ送らない'**
  String get offlineModeDescription;

  /// No description provided for @downloadAllData.
  ///
  /// In ja, this message translates to:
  /// **'全データをダウンロード'**
  String get downloadAllData;

  /// No description provided for @sendPendingData.
  ///
  /// In ja, this message translates to:
  /// **'保留中データを送信'**
  String get sendPendingData;

  /// No description provided for @featureNotReady.
  ///
  /// In ja, this message translates to:
  /// **'この機能は今後対応予定です'**
  String get featureNotReady;

  /// No description provided for @settingsHeader.
  ///
  /// In ja, this message translates to:
  /// **'サーバー設定'**
  String get settingsHeader;

  /// No description provided for @scopeInsufficientTitle.
  ///
  /// In ja, this message translates to:
  /// **'この端末では操作できません'**
  String get scopeInsufficientTitle;

  /// No description provided for @scopeInsufficientDetail.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング済み端末に「{scope}」の権限がありません。/mypage から再ペアリングしてください。'**
  String scopeInsufficientDetail(String scope);

  /// No description provided for @scopeInsufficientCta.
  ///
  /// In ja, this message translates to:
  /// **'端末を再ペアリング'**
  String get scopeInsufficientCta;

  /// No description provided for @qrPairingSuccessTitle.
  ///
  /// In ja, this message translates to:
  /// **'ペアリング完了'**
  String get qrPairingSuccessTitle;

  /// No description provided for @qrPairingSuccessBody.
  ///
  /// In ja, this message translates to:
  /// **'{server} とこの端末が連携しました。'**
  String qrPairingSuccessBody(String server);

  /// No description provided for @qrPairingContinue.
  ///
  /// In ja, this message translates to:
  /// **'続ける'**
  String get qrPairingContinue;

  /// No description provided for @qrPairingNoServerUrl.
  ///
  /// In ja, this message translates to:
  /// **'サーバーURLが設定されていません。設定画面から入力してください。'**
  String get qrPairingNoServerUrl;

  /// No description provided for @qrPairingServerInvalid.
  ///
  /// In ja, this message translates to:
  /// **'設定済みのサーバーURLが不正です: {detail}'**
  String qrPairingServerInvalid(String detail);

  /// No description provided for @qrPairingQrUrlInvalid.
  ///
  /// In ja, this message translates to:
  /// **'QRコードに含まれるサーバーURLが不正です。'**
  String get qrPairingQrUrlInvalid;

  /// No description provided for @qrPairingUrlMismatchExplain.
  ///
  /// In ja, this message translates to:
  /// **'QRコードのサーバーURLが設定と一致しません。安全のため取り消されました。'**
  String get qrPairingUrlMismatchExplain;

  /// No description provided for @qrPairingInstruction.
  ///
  /// In ja, this message translates to:
  /// **'SASO管理画面に表示されたQRコードをスキャンしてください'**
  String get qrPairingInstruction;

  /// No description provided for @connectionTestUrlMissing.
  ///
  /// In ja, this message translates to:
  /// **'サーバーURLが未入力です'**
  String get connectionTestUrlMissing;

  /// No description provided for @connectionTestUrlInvalid.
  ///
  /// In ja, this message translates to:
  /// **'サーバーURLの形式が不正です'**
  String get connectionTestUrlInvalid;

  /// No description provided for @connectionTestHttpError.
  ///
  /// In ja, this message translates to:
  /// **'サーバーが HTTP {statusCode} を返しました'**
  String connectionTestHttpError(int statusCode);

  /// No description provided for @connectionTestFailure.
  ///
  /// In ja, this message translates to:
  /// **'接続失敗: {detail}'**
  String connectionTestFailure(String detail);

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

  /// Home-screen card label that opens the product photo capture page.
  ///
  /// In ja, this message translates to:
  /// **'商品撮影'**
  String get menuProductPhoto;

  /// Home-screen card label for the barcode scan / JAN-ISBN input mode.
  ///
  /// In ja, this message translates to:
  /// **'バーコード入力'**
  String get menuBarcodeInput;

  /// Label for the privacy policy link shown in settings and onboarding. Required by Google Play and App Store for any app that handles personal data.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// Subtitle/description shown next to the privacy policy link in settings. Hints that the link opens an external browser.
  ///
  /// In ja, this message translates to:
  /// **'個人情報の取り扱いについて（外部ブラウザで開きます）'**
  String get privacyPolicySubtitle;

  /// SnackBar shown when url_launcher fails to open the privacy policy URL. Placeholder is the underlying error message.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシーを開けませんでした: {detail}'**
  String privacyPolicyOpenFailed(String detail);
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
