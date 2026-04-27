# SASO Willen Edition — Flutter モバイルターミナル

[![Flutter CI](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/actions/workflows/flutter_ci.yml)
[![Deploys by Netlify](https://www.netlify.com/assets/badges/netlify-badge-color-accent.svg)](https://www.netlify.com)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)

[SASO Willen Edition](https://github.com/Willen-Federation/SASO-Willen-Edition) PHP在庫管理システムのスマートフォン向けハンディターミナルアプリです。倉庫作業者がバーコードスキャン・在庫確認・棚管理をモバイルで行えます。

---

## 機能

| 機能 | 説明 |
|---|---|
| バーコードスキャン | アイテムID・フィーチャーコード・棚IDを即時検索 |
| アイテム検索 | 商品名・カテゴリ・IDで絞り込み |
| 在庫確認 | バリエーション（色・サイズ）ごとの在庫数 |
| カテゴリブラウズ | ネスト階層でのカテゴリツリー表示 |
| 棚ビュー | 棚ID単位でのアイテム一覧 |
| オフライン対応 | SQLiteキャッシュによるネットワーク断対応 |
| フィーチャーフラグ | インフラからリモートで機能ON/OFF切り替え |

## アーキテクチャ

```
Presentation (Riverpod + go_router)
  ├── Feature Flags (OpenFeature準拠 — Debug/Remote/Local provider)
  ├── Auth (OIDC / Firebase Auth / Legacy session — フラグで切り替え)
  └── Push (FCM + Amazon SNS Pinpoint — フラグで切り替え)
Domain (entities, value objects, repository interfaces)
Data (models, datasources: mock/legacy/rest, repositories)
Core (HTTP client, SQLite, secure storage, theme, constants)
```

### APIモード（3段階アダプター）

| モード | 用途 | エンドポイント |
|---|---|---|
| `mock` | 開発・CI（サーバー不要） | インメモリデータ |
| `legacy` | 現行SASAサーバー（M2） | `/item/start`, `/category/list.json` |
| `rest` | M3以降REST API | `/api/v1/*` (Bearer JWT) |

## セットアップ

### 必要環境

- Flutter 3.29+ / Dart 3.7+
- Xcode 16+ (iOS開発)
- iPhone 17 シミュレーター (iOS 26.4, UUID: `6220269A-82B9-4382-B652-952116BA7E80`)

### クイックスタート

```bash
git clone https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter.git
cd SASO-Willen-Edition-Flutter

make setup   # flutter pub get
make gen     # コード生成
make run-ios # iPhone 17シミュレーターで起動
```

### 主要Makeコマンド

```bash
make test           # ユニット + ウィジェットテスト
make test-unit      # ユニットテストのみ
make test-widget    # ウィジェットテストのみ
make test-integration  # iPhone 17で結合テスト
make test-all       # 全テスト
make analyze        # 静的解析
make fmt            # フォーマット
make build-ios-sim  # iOSシミュレータービルド
```

## フィーチャーフラグ

Debugビルドでは全フラグが自動的にONになります。本番・ステージングはFirebase Remote Configからリモート制御します。

| フラグキー | Debug | 説明 |
|---|---|---|
| `ff_push_fcm` | ON | FCMプッシュ通知 |
| `ff_push_sns` | OFF | Amazon SNS Pinpoint |
| `ff_auth_oidc` | ON | OIDC認証 |
| `ff_auth_firebase` | ON | Firebase Auth |
| `ff_rest_api_v1` | OFF | REST API v1 (M3以降) |
| `ff_offline_mode` | ON | オフラインキャッシュ |
| `ff_barcode_scanner` | ON | バーコードスキャン |
| `ff_label_print` | OFF | ラベル印刷 (M3以降) |

## Firebase設定

Firebase機能（FCM・Firebase Auth・Remote Config）を使用するには、各プラットフォームの設定ファイルが必要です。

```bash
# iOS: ios/Runner/GoogleService-Info.plist
# Android: android/app/google-services.json
```

これらのファイルは `.gitignore` で除外されています。テンプレートは `ios/Runner/GoogleService-Info.plist.template` を参照してください。

## コントリビューション

[CONTRIBUTING.md](CONTRIBUTING.md) をご参照ください。

## ライセンス

GPL-3.0 — 詳細は [LICENSE](LICENSE) を参照してください。
