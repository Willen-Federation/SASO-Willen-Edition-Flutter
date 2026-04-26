# REST API v1 リファレンス

SASO M3 リリースで提供される REST API v1 (`/api/v1/*`) のリファレンスです。
Flutter アプリでは `ff_rest_api_v1` フィーチャーフラグが ON のときに使用されます。

!!! info "認証"
    全エンドポイントは Bearer JWT (RS256, 15 分有効) で認証されます。
    モバイルアプリ側はサーバー設定ページから取得・保存します。

!!! warning "ステータス"
    M3 リリース前のため、本リファレンスは **設計時点** のスナップショットです。
    実装側 ([rest_api_client.dart](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/blob/main/lib/data/datasources/remote/v1/rest_api_client.dart)) と齟齬がある場合は実装が正です。

[OpenAPI 3.0 仕様書ファイル (openapi.yaml)](openapi.yaml){ download="saso-rest-api-v1.openapi.yaml" } をダウンロードして Postman / Insomnia / OpenAPI Generator にインポートできます。

---

## ベース URL

| 環境 | URL |
|---|---|
| ステージング | `https://staging.api.example.com` |
| 本番 | `https://api.example.com` |

すべてのリクエストに `Authorization: Bearer <JWT>` ヘッダーを付与してください。
レスポンスは `application/json`、エラーは [RFC 7807 Problem Details](https://datatracker.ietf.org/doc/html/rfc7807) (`application/problem+json`) です。

---

## エンドポイント一覧

| メソッド | パス | 概要 |
|---|---|---|
| GET | [`/api/v1/items/{itemId}`](#get-itemsitemid) | アイテム詳細を取得 |
| GET | [`/api/v1/items`](#get-items) | アイテム検索 |
| GET | [`/api/v1/categories`](#get-categories) | カテゴリ階層を取得 |
| GET | [`/api/v1/shelves/{shelfId}`](#get-shelvesshelfid) | 棚詳細を取得 |
| GET | [`/api/v1/shelves/{shelfId}/items`](#get-shelvesshelfiditems) | 棚に紐づくアイテム一覧 |

---

## GET /items/{itemId}

アイテム ID を指定して詳細を取得します。

**パスパラメータ**

| 名前 | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `itemId` | string | ✓ | 内部アイテム ID (例: `ITEM-001`) |

**リクエスト例**

```http
GET /api/v1/items/ITEM-001 HTTP/1.1
Host: api.example.com
Authorization: Bearer <JWT>
Accept: application/json
```

**レスポンス (200 OK)**

```json
{
  "id": "ITEM-001",
  "name": "メンズジャケット (ネイビー)",
  "description": null,
  "categoryId": "CAT-OUTERWEAR",
  "categoryName": "アウター",
  "features": [
    {
      "code": "BLU-M",
      "colorCode": "BLU",
      "sizeCode": "M",
      "colorLabel": "ネイビー",
      "sizeLabel": "M",
      "stockCount": 12,
      "shelfId": "SHELF-A-12"
    }
  ],
  "registeredAt": "2024-04-01T09:00:00Z",
  "updatedAt": "2024-04-15T17:30:00Z"
}
```

**エラー**

| ステータス | コード | 意味 |
|---|---|---|
| 401 | `SASO-DOMAIN-401` | 認証失敗 (JWT 無効・失効) |
| 404 | `SASO-DOMAIN-1042` | 指定 ID のアイテムが存在しない |
| 5xx | `SASO-DOMAIN-5xx` | サーバー側エラー |

---

## GET /items

アイテムを検索します。

**クエリパラメータ**

| 名前 | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `q` | string |  | 商品名・ID 部分一致 |
| `category_id` | string |  | カテゴリで絞り込み |
| `limit` | integer |  | 取得件数上限 (1〜100, 既定 20) |

**リクエスト例**

```http
GET /api/v1/items?q=ジャケット&category_id=CAT-OUTERWEAR&limit=20 HTTP/1.1
Host: api.example.com
Authorization: Bearer <JWT>
```

**レスポンス (200 OK)**

```json
{
  "data": [
    {
      "id": "ITEM-001",
      "name": "メンズジャケット (ネイビー)",
      "categoryId": "CAT-OUTERWEAR",
      "features": [],
      "registeredAt": "2024-04-01T09:00:00Z"
    }
  ]
}
```

---

## GET /categories

カテゴリ階層を root から順にネスト構造で返します。

**リクエスト例**

```http
GET /api/v1/categories HTTP/1.1
Host: api.example.com
Authorization: Bearer <JWT>
```

**レスポンス (200 OK)**

```json
{
  "data": [
    {
      "id": "CAT-OUTERWEAR",
      "name": "アウター",
      "parentId": null,
      "depth": 0,
      "children": [
        {
          "id": "CAT-JACKET",
          "name": "ジャケット",
          "parentId": "CAT-OUTERWEAR",
          "depth": 1,
          "children": []
        }
      ]
    }
  ]
}
```

---

## GET /shelves/{shelfId}

棚 ID を指定して詳細を取得します。`itemIds` には棚に登録されているアイテムの ID 配列が含まれます。

**パスパラメータ**

| 名前 | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `shelfId` | string | ✓ | 棚 ID (例: `SHELF-A-12`) |

**レスポンス (200 OK)**

```json
{
  "id": "SHELF-A-12",
  "label": "倉庫A 12番棚",
  "location": "1階 通路A",
  "itemIds": ["ITEM-001", "ITEM-002"]
}
```

---

## GET /shelves/{shelfId}/items

棚に登録されているアイテムを一括取得します。

**レスポンス (200 OK)**

```json
{
  "data": [
    {
      "id": "ITEM-001",
      "name": "メンズジャケット",
      "categoryId": "CAT-OUTERWEAR",
      "features": [],
      "registeredAt": "2024-04-01T09:00:00Z"
    }
  ]
}
```

---

## スキーマ

### Item

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `id` | string | ✓ | アイテム ID |
| `name` | string | ✓ | 商品名 |
| `description` | string |  | 商品説明 |
| `categoryId` | string | ✓ | カテゴリ ID |
| `categoryName` | string |  | カテゴリ名 (展開済み) |
| `features` | Feature[] |  | 色×サイズバリエーション (既定: `[]`) |
| `registeredAt` | string (date-time) | ✓ | 登録日時 (ISO 8601) |
| `updatedAt` | string (date-time) |  | 最終更新日時 |

### Feature

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `code` | string | ✓ | 色サイズコード (例: `BLU-M`) |
| `colorCode` | string | ✓ | 色コード |
| `sizeCode` | string | ✓ | サイズコード |
| `colorLabel` | string |  | 色の表示名 |
| `sizeLabel` | string |  | サイズの表示名 |
| `stockCount` | integer |  | 在庫数 (既定: `0`) |
| `shelfId` | string |  | 棚 ID |

### Category

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `id` | string | ✓ | カテゴリ ID |
| `name` | string | ✓ | カテゴリ名 |
| `parentId` | string |  | 親カテゴリ ID (root は `null`) |
| `children` | Category[] |  | 子カテゴリ (既定: `[]`) |
| `depth` | integer |  | 階層深度 (root が 0) |

### Shelf

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `id` | string | ✓ | 棚 ID |
| `label` | string |  | 棚ラベル |
| `location` | string |  | 物理的な配置場所 |
| `itemIds` | string[] |  | 登録アイテム ID (既定: `[]`) |

### ProblemDetails (エラーレスポンス)

[RFC 7807](https://datatracker.ietf.org/doc/html/rfc7807) 準拠 + SASO ドメインコード。

| フィールド | 型 | 必須 | 説明 |
|---|---|:---:|---|
| `type` | string (URI) | ✓ | 問題タイプを識別する URI |
| `title` | string | ✓ | 概要 |
| `status` | integer | ✓ | HTTP ステータスコード |
| `detail` | string |  | 詳細メッセージ |
| `instance` | string (URI) |  | 発生インスタンス URI |
| `code` | string |  | SASO ドメインコード (`SASO-DOMAIN-NNNN`) |

エラーレスポンス例:

```json
{
  "type": "https://saso.example.com/errors/item-not-found",
  "title": "Item not found",
  "status": 404,
  "detail": "Item with id ITEM-999 does not exist",
  "code": "SASO-DOMAIN-1042"
}
```
