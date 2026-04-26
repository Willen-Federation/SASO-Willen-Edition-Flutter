# 変更履歴

すべての変更は [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) 形式で記録されています。  
バージョニングは [Semantic Versioning](https://semver.org/spec/v2.0.0.html) に準拠します。

> 完全な変更履歴は [CHANGELOG.md](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/CHANGELOG.md) を参照してください。

---

## [Unreleased]

### 追加

- FCM プロダクション実装（トークンリフレッシュ、フォアグラウンド通知表示）
- SNS Pinpoint プロダクション実装（`Amplify.configure()` の修正）
- プッシュ通知タップ時のディープリンクルーティング（`PushNotificationStartup`）
- iOS `AppDelegate.swift` に `UNUserNotificationCenterDelegate` を追加（フォアグラウンド通知表示）
- Android `POST_NOTIFICATIONS` 権限追加（Android 13+）
- MkDocs Material ドキュメントサイト（GitHub Pages 自動デプロイ）
- `lib/amplifyconfiguration.dart` スタブ（コード編集なしでビルド可能）

---

## [0.1.0] — 2026-04-26

### 追加

- Flutter プロジェクト初期化（Clean Architecture / DDD）
- OpenFeature 準拠フィーチャーフラグ（Debug: 全 ON、Release: Firebase Remote Config）
- 3 段階 API アダプター（Mock / Legacy / REST v1）
- FCM + SNS Pinpoint 両方バンドル（フラグで切り替え）
- OIDC / Firebase / Legacy セッション認証（フラグで切り替え）
- バーコードスキャン（mobile_scanner 6.x、iOS 15.5+）
- アイテム検索・詳細・カテゴリブラウザ・棚ビュー
- SQLite オフラインキャッシュ（オフラインファースト）
- ユニット・ウィジェット・インテグレーションテスト
- Makefile・GitHub Actions CI
- GPL-3.0 オープンソースドキュメント一式
