# SASO Willen Edition — はじめに

**SASO Willen Edition** は、SASO倉庫在庫管理システム向けのFlutterモバイルターミナルです。  
倉庫作業者がスマートフォンで在庫確認・バーコードスキャン・棚管理を行えます。

---

## 動作環境

| 項目 | 要件 |
|------|------|
| Flutter | 3.29 以上 |
| Dart | 3.7 以上 |
| iOS | 15.5 以上（iPhone 11 以降推奨） |
| Android | API 23（Android 6.0）以上 |
| Xcode | 16 以上（iOS ビルド時） |

---

## クイックスタート（5 分）

コードを一行も編集せずにアプリを起動できます。

### 1. リポジトリをクローン

```bash
git clone https://github.com/willen-federation/saso-willen-edition-flutter.git
cd saso-willen-edition-flutter
```

### 2. 依存パッケージを取得

```bash
flutter pub get
```

### 3. シミュレーターで起動（モックモード）

サーバー・Firebase 設定なしでそのまま起動できます。

```bash
# 利用可能なデバイス一覧を表示
flutter devices

# iPhone シミュレーターで起動
flutter run -d <デバイスID>
```

起動後、バナーに **「モックモード（サーバー不要）」** と表示されれば成功です。

!!! tip "モックデータについて"
    モックモードでは架空の在庫データが表示されます。実際の SASO サーバーへの接続は [レガシー API 接続ガイド](api/legacy.md) を参照してください。

---

## 本番環境へのセットアップ（コード編集不要）

プッシュ通知・認証を有効にするには、以下のファイルを Firebase / AWS Console からダウンロードして所定の場所に配置するだけです。

| 機能 | 必要なファイル | 配置場所 |
|------|--------------|---------|
| iOS FCM / Firebase Auth | `GoogleService-Info.plist` | `ios/Runner/` |
| Android FCM / Firebase Auth | `google-services.json` | `android/app/` |
| SNS Pinpoint（オプション） | `lib/amplifyconfiguration.dart` | `lib/` |

詳しくは各セットアップガイドを参照してください。

- [Firebase セットアップ](setup/firebase.md)
- [AWS Amplify Pinpoint セットアップ](setup/amplify.md)
- [iOS デプロイ](setup/ios.md)
- [Android デプロイ](setup/android.md)

---

## アーキテクチャ概要

```
Presentation  (Riverpod + go_router)
    ↓
Feature Flags (OpenFeature — Debug: 全ON / Release: Firebase Remote Config)
    ↓
Auth          (Legacy Cookie / OIDC / Firebase Auth — フラグ切り替え)
Push          (FCM / SNS Pinpoint — フラグ切り替え)
    ↓
Domain        (Entity / ValueObject / Repository interface / UseCase)
    ↓
Data          (Mock / Legacy API / REST v1 アダプター + SQLite キャッシュ)
```

---

## ライセンス

GPL-3.0 — 詳しくは [LICENSE](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/LICENSE) を参照してください。
GPL-3.0 は [OSI 承認のオープンソースライセンス](https://opensource.org/licenses/GPL-3.0) です。

行動規範については [行動規範ページ](code-of-conduct.md) を、変更履歴は [変更履歴](changelog.md) をご覧ください。

---

## ホスティング / Hosting

このサイトは [Netlify](https://www.netlify.com) によってホスティングされています。
This site is hosted by [Netlify](https://www.netlify.com).

[![Deploys by Netlify](https://www.netlify.com/img/global/badges/netlify-color-accent.svg)](https://www.netlify.com)
