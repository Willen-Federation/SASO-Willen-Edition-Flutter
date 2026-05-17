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

  @override
  String get samlProviderNotActive => 'SAMLプロバイダーが有効ではありません';

  @override
  String get pairingFailed => 'ペアリング失敗';

  @override
  String pairingFailedWithStatus(int status) =>
      'ペアリング失敗 (HTTP $status)';

  @override
  String pairingNetworkError(String details) =>
      'ペアリング通信エラー: $details';
}
