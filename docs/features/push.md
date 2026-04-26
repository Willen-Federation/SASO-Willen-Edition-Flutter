# プッシュ通知

SASO Willen Edition は **FCM**（Firebase Cloud Messaging）と **Amazon SNS Pinpoint** の両方をバンドルし、フィーチャーフラグで使用するサービスを切り替えます。

---

## フィーチャーフラグ

| フラグキー | デフォルト（Debug） | 説明 |
|-----------|-----------------|------|
| `ff_push_fcm` | ON | FCM プッシュ通知 |
| `ff_push_sns` | OFF | SNS Pinpoint プッシュ通知 |

`ff_push_sns` が ON の場合は SNS が優先されます。両方 OFF の場合はプッシュ通知が無効になります。

---

## サービス選択フロー

```
起動時
  ↓
ff_push_sns = true？ → SnsPushService（AWS Amplify Pinpoint）
  ↓ No
ff_push_fcm = true？ → FcmPushService（Firebase Messaging）
  ↓ No
NoOpPushService（通知なし）
```

---

## 通知のルーティング

通知データの `route` フィールドに GoRouter パスを設定することで、通知タップ時に特定の画面に遷移できます。

### 送信側ペイロード例

```json
{
  "notification": {
    "title": "在庫アラート",
    "body": "アイテム「ネジ M3」の在庫が少なくなっています"
  },
  "data": {
    "route": "/items/26040001"
  }
}
```

### 対応している route パス

| パス | 画面 |
|------|------|
| `/home` | ホーム |
| `/items/search` | アイテム検索 |
| `/items/:id` | アイテム詳細（ID を指定） |
| `/scanner` | バーコードスキャン |
| `/categories` | カテゴリブラウザ |
| `/shelves/:id` | 棚ビュー |

---

## 動作確認

Firebase Cloud Messaging テストツールで手動送信できます：

1. Firebase コンソール → **「Messaging」→「新しいキャンペーン」→「通知」**
2. **タイトル** と **本文** を入力
3. **「テストメッセージを送信」** で端末の FCM トークンを入力
4. **「テスト」** をクリック

---

## セットアップ

- FCM の設定方法 → [Firebase セットアップ](../setup/firebase.md)
- SNS Pinpoint の設定方法 → [AWS Amplify Pinpoint セットアップ](../setup/amplify.md)
