# Flutter クライアント API 要件定義

Flutter モバイルターミナルが必要とするサーバー API の一覧です。  
サーバー実装チームへの依頼仕様として使用してください。

---

## ステータス凡例

| マーク | 意味 |
|:---:|---|
| ✅ | サーバー実装済み (M3 コミット 4267ef4 以降) |
| 🔜 | OpenAPI 定義済み・サーバー実装待ち |
| ❌ | 未定義・新規実装依頼 |

---

## 1. 認証・デバイス管理

| ステータス | メソッド | パス | 概要 |
|:---:|---|---|---|
| ✅ | `POST` | `/api/v1/mobile/pairing-codes` | QR ペアリングコード生成 |
| ✅ | `POST` | `/api/v1/mobile/connect` | QR トークン → JWT ペア交換 |
| ✅ | `POST` | `/api/v1/mobile/token/refresh` | アクセストークンリフレッシュ |
| ✅ | `GET` | `/api/v1/mobile/tokens` | 登録デバイストークン一覧 |
| ✅ | `DELETE` | `/api/v1/mobile/tokens/{id}` | デバイストークン無効化 |

---

## 2. プッシュ通知トークン管理 ❌ 新規実装依頼

Flutter アプリは起動時に FCM / SNS Pinpoint のデバイストークンを取得します。  
**サーバーがこのトークンを保持しない限りプッシュ通知を送信できません。**

### `PUT /api/v1/mobile/push-token`

デバイスのプッシュ通知トークンを登録・更新します。  
Bearer JWT で認証済みのデバイスに紐づけて保存してください。

**リクエスト**

```json
{
  "token": "fcm-device-token-string",
  "provider": "fcm",
  "platform": "ios"
}
```

| フィールド | 型 | 必須 | 値 |
|---|---|:---:|---|
| `token` | string | ✓ | FCM / SNS Pinpoint デバイストークン |
| `provider` | string | ✓ | `"fcm"` または `"sns"` |
| `platform` | string | ✓ | `"ios"` または `"android"` |

**レスポンス**

```
204 No Content
```

---

### `DELETE /api/v1/mobile/push-token`

ログアウト時にプッシュトークンを削除します。

**レスポンス**

```
204 No Content
```

---

## 3. 在庫・アイテム管理

| ステータス | メソッド | パス | 概要 |
|:---:|---|---|---|
| 🔜 | `GET` | `/api/v1/items/{itemId}` | アイテム詳細取得 |
| 🔜 | `GET` | `/api/v1/items` | アイテム検索 (`q`, `category_id`, `limit`) |

### `GET /api/v1/items/{itemId}` — レスポンス仕様

```json
{
  "id": "ITEM-001",
  "name": "メンズジャケット (ネイビー)",
  "description": "説明文 (nullable)",
  "categoryId": "CAT-OUTERWEAR",
  "categoryName": "アウターウェア (nullable)",
  "features": [
    {
      "code": "BLU-M",
      "colorCode": "BLU",
      "sizeCode": "M",
      "colorLabel": "ネイビー",
      "sizeLabel": "M (中)",
      "stockCount": 12,
      "shelfId": "SHELF-A-12"
    }
  ],
  "registeredAt": "2026-01-15T09:00:00Z",
  "updatedAt": "2026-04-01T14:30:00Z"
}
```

---

### `GET /api/v1/items` — クエリパラメータ

| パラメータ | 型 | 説明 |
|---|---|---|
| `q` | string | 商品名・ID の部分一致検索 |
| `category_id` | string | カテゴリ ID で絞り込み |
| `limit` | integer | 最大件数 (1–100、既定 20) |

**レスポンス**

```json
{ "data": [ /* Item の配列 */ ] }
```

---

## 4. 在庫数・棚アサイン更新 ❌ 新規実装依頼

ハンディターミナルから在庫調整・棚移動を行うために必要です。

### `PATCH /api/v1/items/{itemId}/features/{featureCode}`

アイテムの特定バリエーション（色×サイズ）の在庫数または棚 ID を部分更新します。

**リクエスト**

```json
{
  "stockCount": 15,
  "shelfId": "SHELF-B-03"
}
```

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `stockCount` | integer (≥0) | — | 更新後在庫数。省略時は変更なし |
| `shelfId` | string \| null | — | 棚 ID。`null` で棚アサイン解除 |

**レスポンス**

```json
{
  "code": "BLU-M",
  "colorCode": "BLU",
  "sizeCode": "M",
  "colorLabel": "ネイビー",
  "sizeLabel": "M (中)",
  "stockCount": 15,
  "shelfId": "SHELF-B-03"
}
```

**エラー**

| HTTP | SASO コード | 説明 |
|---|---|---|
| `400` | `SASO-ITEM-4001` | stockCount が負数 |
| `404` | `SASO-ITEM-4040` | itemId が存在しない |
| `404` | `SASO-ITEM-4041` | featureCode が存在しない |
| `404` | `SASO-SHELF-4040` | 指定 shelfId が存在しない |

---

## 5. カテゴリ

| ステータス | メソッド | パス | 概要 |
|:---:|---|---|---|
| 🔜 | `GET` | `/api/v1/categories` | カテゴリツリー取得 |

**レスポンス**

```json
{
  "data": [
    {
      "id": "CAT-ROOT",
      "name": "全カテゴリ",
      "parentId": null,
      "depth": 0,
      "children": [
        {
          "id": "CAT-OUTERWEAR",
          "name": "アウターウェア",
          "parentId": "CAT-ROOT",
          "depth": 1,
          "children": []
        }
      ]
    }
  ]
}
```

---

## 6. 棚管理

| ステータス | メソッド | パス | 概要 |
|:---:|---|---|---|
| 🔜 | `GET` | `/api/v1/shelves/{shelfId}` | 棚詳細取得 |
| 🔜 | `/api/v1/shelves/{shelfId}/items` | 棚に紐づくアイテム一覧 |

---

## 7. ラベル印刷 ❌ 新規実装依頼

`ff_label_print` フィーチャーフラグが ON のとき Flutter から呼び出します。  
レガシー API の `/shelf/outputPdf?id={id}` に相当します。

### `GET /api/v1/items/{itemId}/label`

アイテムの PDF ラベルを返します。

**クエリパラメータ**

| パラメータ | 型 | 既定 | 説明 |
|---|---|---|---|
| `feature_code` | string | — | 特定バリエーションのラベルに絞る (省略時は全バリエーション) |
| `format` | string | `pdf` | `pdf` または `zpl` |

**レスポンス**

```
200 OK
Content-Type: application/pdf   (format=pdf の場合)
Content-Type: text/plain        (format=zpl の場合)
Content-Disposition: attachment; filename="ITEM-001.pdf"

<バイナリ or ZPL テキスト>
```

---

### `GET /api/v1/shelves/{shelfId}/label`

棚ラベル PDF を返します（レガシー `/shelf/outputPdf` の REST v1 相当）。

**クエリパラメータ**

| パラメータ | 型 | 既定 | 説明 |
|---|---|---|---|
| `format` | string | `pdf` | `pdf` または `zpl` |

**レスポンス**

```
200 OK
Content-Type: application/pdf
Content-Disposition: attachment; filename="SHELF-A-12.pdf"

<バイナリ>
```

---

## 8. 設定バンドル・フィーチャーフラグ

| ステータス | メソッド | パス | 概要 |
|:---:|---|---|---|
| ✅ | `GET` | `/api/v1/mobile/config` | オフライン設定バンドル取得 |
| ✅ | `GET` | `/api/v1/feature-flags` | フラグ一覧 |
| ✅ | `POST` | `/api/v1/feature-flags` | フラグ作成 |
| ✅ | `GET` | `/api/v1/feature-flags/{key}` | フラグ取得 |
| ✅ | `PATCH` | `/api/v1/feature-flags/{key}` | フラグ部分更新 |
| ✅ | `DELETE` | `/api/v1/feature-flags/{key}` | フラグ削除 |

### 設定バンドル レスポンス仕様

```json
{
  "version": "a3f2c1d8...",
  "generated_at": "2026-04-27T01:00:00Z",
  "feature_flags": [
    {
      "key": "ff_rest_api_v1",
      "description": "REST API v1 を有効化",
      "enabled": true,
      "rollout_percent": 100,
      "conditions": {}
    }
  ]
}
```

`version` は SHA-256 ハッシュです。前回取得時の `version` と比較して変化がない場合はキャッシュを継続使用できます。

---

## 9. メタ

| ステータス | メソッド | パス | 概要 |
|:---:|---|---|---|
| ✅ | `GET` | `/api/v1/health` | ヘルスチェック (認証不要) |
| ✅ | `GET` | `/api/v1/openapi.yaml` | OpenAPI 仕様書取得 |

---

## 認証共通仕様

すべての認証が必要なエンドポイントに対して、以下のヘッダーを付与します：

```
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

| 項目 | 値 |
|---|---|
| JWT アルゴリズム | HS256 |
| アクセストークン有効期間 | 1 時間 |
| リフレッシュトークン有効期間 | 約 1 年 (ローテーション式) |
| トークン失効時のステータス | `401 Unauthorized` |

---

## エラー形式 (RFC 7807)

```json
{
  "type": "https://saso.example.com/errors/item-not-found",
  "title": "Item not found",
  "status": 404,
  "detail": "Item 'ITEM-999' does not exist",
  "code": "SASO-ITEM-4040",
  "traceId": "550e8400-e29b-41d4-a716-446655440000"
}
```

`code` フィールドのフォーマット: `SASO-{DOMAIN}-{4桁番号}`

| ドメイン | 対象 |
|---|---|
| `AUTH` | 認証・認可 |
| `ITEM` | アイテム操作 |
| `SHELF` | 棚操作 |
| `LABEL` | ラベル印刷 |
| `PUSH` | プッシュ通知 |
| `INSTALL` | インストール・設定 |
| `INFRA` | インフラ・サーバーエラー |

---

## 優先度まとめ

| 優先度 | エンドポイント | 理由 |
|:---:|---|---|
| **高** | 在庫・カテゴリ・棚 (🔜) | アプリの中核機能。未実装だと基本操作不可 |
| **高** | `PUT /api/v1/mobile/push-token` | プッシュ通知機能が未完成のまま |
| **中** | `PATCH /api/v1/items/{itemId}/features/{featureCode}` | 在庫調整・棚移動操作 |
| **低** | ラベル印刷 (`/label`) | `ff_label_print` フラグで制御。初期リリース後でも可 |

---

*このドキュメントは [openapi.yaml](openapi.yaml) の完全なスキーマ定義と対応しています。*  
*最終更新: 2026-04-27*
