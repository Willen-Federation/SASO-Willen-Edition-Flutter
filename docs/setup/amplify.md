# AWS Amplify Pinpoint セットアップ

Amazon SNS Pinpoint によるプッシュ通知を有効にするためのガイドです。  
`ff_push_sns` フラグが `true` のときのみ使用されます（デフォルト: `false`）。

!!! info "FCM との違い"
    SASO Willen Edition は FCM（Firebase Cloud Messaging）と SNS Pinpoint の両方をバンドルしています。  
    フィーチャーフラグで使用するサービスを切り替えます。  
    **通常は FCM のみで十分です。** Pinpoint は大規模セグメント配信や AWS 統合が必要な場合に使用します。

---

## 前提条件

- AWS アカウント
- IAM ユーザー（Pinpoint 操作権限付き）

---

## 手順

### 1. Amplify CLI をインストール

```bash
npm install -g @aws-amplify/cli
amplify configure
```

### 2. Pinpoint プロジェクトを作成

1. [AWS Console](https://console.aws.amazon.com/pinpoint/) → **Amazon Pinpoint** を開く
2. **「プロジェクトを作成」** をクリック
3. プロジェクト名を入力（例: `saso-willen`）
4. **「プロジェクト ID」** をメモしておく（後で使用）

### 3. プッシュ通知チャネルを設定

=== "iOS (APNs)"

    1. Pinpoint プロジェクト → **「設定」→「プッシュ通知」**
    2. **「Apple Push Notification Service (APNs)」** を有効化
    3. Apple Developer Console で取得した `.p8` 認証キーをアップロード

=== "Android (FCM)"

    1. Pinpoint プロジェクト → **「設定」→「プッシュ通知」**
    2. **「Firebase Cloud Messaging (FCM)」** を有効化
    3. Firebase コンソールの **「プロジェクト設定」→「サービスアカウント」** から  
       サーバーキーを取得して入力

### 4. amplifyconfiguration.dart を更新

`lib/amplifyconfiguration.dart` を開き、`REPLACE_WITH_YOUR_PINPOINT_APP_ID` を  
手順 2 でメモした **プロジェクト ID** に置き換えてください：

```dart
const amplifyconfig = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "notifications": {
    "plugins": {
      "awsPinpointNotificationsPlugin": {
        "pinpointAnalytics": {
          "appId": "YOUR_PINPOINT_APP_ID_HERE",  // ← ここを変更
          "region": "ap-northeast-1"
        },
        "pinpointTargeting": {
          "region": "ap-northeast-1"
        }
      }
    }
  }
}
''';
```

!!! warning "注意"
    実際の App ID が含まれたファイルは **Git にコミットしないでください。**  
    `.gitignore` に `lib/amplifyconfiguration.dart` を追加してください。  
    スタブファイル（`REPLACE_WITH_YOUR_PINPOINT_APP_ID` 入り）のみコミットします。

### 5. ff_push_sns フラグを有効化

Firebase Remote Config で `ff_push_sns` を `true` に設定するか、  
アプリ内の **「サーバー設定」→「フィーチャーフラグ」** で有効にしてください。

---

## 確認

```bash
flutter run --debug
```

デバッグビルドでは全フラグが ON になるため、アプリ起動時に Pinpoint への接続が試みられます。  
ログに `Amplify configured successfully` が表示されれば成功です。
