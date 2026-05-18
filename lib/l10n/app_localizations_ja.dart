// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'SASO Willen';

  @override
  String get home => 'ホーム';

  @override
  String get items => 'アイテム';

  @override
  String get categories => 'カテゴリ';

  @override
  String get scanner => 'スキャン';

  @override
  String get shelf => '棚';

  @override
  String get settings => '設定';

  @override
  String get search => '検索';

  @override
  String get searchItems => 'アイテムを検索';

  @override
  String get searchHint => 'アイテムIDまたは名前を入力';

  @override
  String get itemId => 'アイテムID';

  @override
  String get itemName => 'アイテム名';

  @override
  String get itemFeatures => 'バリエーション';

  @override
  String get itemRegisteredAt => '登録日';

  @override
  String get itemStatus => 'ステータス';

  @override
  String get itemStatusActive => 'アクティブ';

  @override
  String get itemStatusArchived => 'アーカイブ';

  @override
  String get itemStatusDiscontinued => '廃盤';

  @override
  String get itemStatusPending => '保留中';

  @override
  String get itemStatusInStorage => '保管中';

  @override
  String get itemStatusInUse => '利用中';

  @override
  String get itemStatusForSale => '販売中';

  @override
  String get itemStatusReserved => '仮押さえ';

  @override
  String get itemStatusShipped => '発送済み';

  @override
  String get itemStatusChange => 'ステータス変更';

  @override
  String get itemStatusUpdated => 'ステータスを更新しました';

  @override
  String itemStatusUpdateFailed(String detail) {
    return 'ステータス変更に失敗しました: $detail';
  }

  @override
  String get categoryName => 'カテゴリ名';

  @override
  String get noChildren => 'サブカテゴリなし';

  @override
  String get shelfId => '棚ID';

  @override
  String get shelfItems => '棚のアイテム';

  @override
  String get serverUrl => 'サーバーURL';

  @override
  String get serverUrlHint => '例: https://saso.example.com';

  @override
  String get apiMode => 'APIモード';

  @override
  String get apiModeMock => 'モック（サーバー不要）';

  @override
  String get apiModeLegacy => 'レガシー（互換モード）';

  @override
  String get apiModeRest => 'REST v1';

  @override
  String get testConnection => '接続テスト';

  @override
  String get connectionSuccess => '接続成功';

  @override
  String get connectionFailed => '接続失敗';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get scanBarcode => 'バーコードをスキャン';

  @override
  String get scanResult => 'スキャン結果';

  @override
  String get loading => '読み込み中...';

  @override
  String get noData => 'データがありません';

  @override
  String get error => 'エラー';

  @override
  String get retry => '再試行';

  @override
  String get login => 'ログイン';

  @override
  String get logout => 'ログアウト';

  @override
  String get username => 'ユーザー名';

  @override
  String get password => 'パスワード';

  @override
  String get loginFailed => 'ログインに失敗しました';

  @override
  String get loginScreenTitle => 'ログイン';

  @override
  String get loginWithBrowser => 'ブラウザでログイン';

  @override
  String get loginWithSso => 'SSOでログイン';

  @override
  String get loginWithQr => 'QRコードでペアリング';

  @override
  String get loginStandard => '標準ログイン';

  @override
  String get samlLoginTitle => 'SSOログイン';

  @override
  String get samlLoginCancelled => 'SAMLログインがキャンセルされました';

  @override
  String samlLoginInvalidUrl(String detail) {
    return 'SSOログインURLが無効です: $detail';
  }

  @override
  String get qrPairingTitle => 'QRペアリング';

  @override
  String get qrPairingInProgress => 'ペアリング中...';

  @override
  String qrPairingFailed(int statusCode) {
    return 'ペアリング失敗 (HTTP $statusCode)';
  }

  @override
  String get qrPairingUrlMismatch => 'QRコードのサーバーURLが設定と一致しません';

  @override
  String get qrPairingUrlInvalid => 'サーバーURLはHTTPSである必要があります';

  @override
  String authLegacyHttpsRequired(String detail) {
    return 'サーバーURLはHTTPSである必要があります: $detail';
  }

  @override
  String get authSessionExpired => 'セッションの有効期限が切れました。再度ログインしてください。';

  @override
  String authNetworkError(String detail) {
    return 'ネットワークエラー: $detail';
  }

  @override
  String get pairedDevicesSection => 'ペアリング済み端末';

  @override
  String get manageDevicesOnWeb => 'ペアリング端末をブラウザで管理';

  @override
  String manageDevicesOnWebSubtitle(String url) {
    return '$url をブラウザで開いて、端末の取り消しや名前変更を行います。';
  }

  @override
  String openWebPortalFailed(String detail) {
    return 'ブラウザを開けませんでした: $detail';
  }

  @override
  String get settingsSaved => '設定を保存しました';

  @override
  String get offlineBadge => 'オフライン';

  @override
  String get offlineMode => 'オフラインモード';

  @override
  String get offlineModeDescription => 'ONにすると書き込みをキューに蓄積し、サーバーへ送らない';

  @override
  String get downloadAllData => '全データをダウンロード';

  @override
  String get sendPendingData => '保留中データを送信';

  @override
  String get featureNotReady => 'この機能は今後対応予定です';

  @override
  String get settingsHeader => 'サーバー設定';

  @override
  String get scopeInsufficientTitle => 'この端末では操作できません';

  @override
  String scopeInsufficientDetail(String scope) {
    return 'ペアリング済み端末に「$scope」の権限がありません。/mypage から再ペアリングしてください。';
  }

  @override
  String get scopeInsufficientCta => '端末を再ペアリング';

  @override
  String get qrPairingSuccessTitle => 'ペアリング完了';

  @override
  String qrPairingSuccessBody(String server) {
    return '$server とこの端末が連携しました。';
  }

  @override
  String get qrPairingContinue => '続ける';

  @override
  String get qrPairingNoServerUrl => 'サーバーURLが設定されていません。設定画面から入力してください。';

  @override
  String qrPairingServerInvalid(String detail) {
    return '設定済みのサーバーURLが不正です: $detail';
  }

  @override
  String get qrPairingQrUrlInvalid => 'QRコードに含まれるサーバーURLが不正です。';

  @override
  String get qrPairingUrlMismatchExplain =>
      'QRコードのサーバーURLが設定と一致しません。安全のため取り消されました。';

  @override
  String get qrPairingInstruction => 'SASO管理画面に表示されたQRコードをスキャンしてください';

  @override
  String get connectionTestUrlMissing => 'サーバーURLが未入力です';

  @override
  String get connectionTestUrlInvalid => 'サーバーURLの形式が不正です';

  @override
  String connectionTestHttpError(int statusCode) {
    return 'サーバーが HTTP $statusCode を返しました';
  }

  @override
  String connectionTestFailure(String detail) {
    return '接続失敗: $detail';
  }

  @override
  String get featureFlags => '機能フラグ';

  @override
  String get flagRestApi => 'REST API v1';

  @override
  String get flagPushFcm => 'FCMプッシュ通知';

  @override
  String get flagPushSns => 'Amazon SNSプッシュ通知';

  @override
  String get flagAuthOidc => 'OIDC認証';

  @override
  String get flagAuthFirebase => 'Firebase認証';

  @override
  String get flagOfflineMode => 'オフラインモード';

  @override
  String get flagBarcodeScanner => 'バーコードスキャン';

  @override
  String get flagLabelPrint => 'ラベル印刷';
}
