# Flutter Client API Requirements

A complete list of server APIs required by the Flutter mobile terminal.  
Use this document as a specification for the server implementation team.

---

## Status Legend

| Mark | Meaning |
|:---:|---|
| ✅ | Implemented on server (M3 commit 4267ef4+) |
| 🔜 | Defined in OpenAPI — awaiting server implementation |
| ❌ | Not yet defined — new implementation request |

---

## 1. Authentication & Device Management

| Status | Method | Path | Description |
|:---:|---|---|---|
| ✅ | `POST` | `/api/v1/mobile/pairing-codes` | Generate QR pairing code |
| ✅ | `POST` | `/api/v1/mobile/connect` | Exchange QR token for JWT pair |
| ✅ | `POST` | `/api/v1/mobile/token/refresh` | Refresh access token |
| ✅ | `GET` | `/api/v1/mobile/tokens` | List registered device tokens |
| ✅ | `DELETE` | `/api/v1/mobile/tokens/{id}` | Revoke device token |

---

## 2. Push Notification Token Management ❌ New Request

The Flutter app retrieves an FCM / SNS Pinpoint device token at startup.  
**The server cannot send push notifications without storing this token.**

### `PUT /api/v1/mobile/push-token`

Register or update the device's push notification token.  
Associate it with the authenticated device (identified by the Bearer JWT).

**Request**

```json
{
  "token": "fcm-device-token-string",
  "provider": "fcm",
  "platform": "ios"
}
```

| Field | Type | Required | Values |
|---|---|:---:|---|
| `token` | string | ✓ | FCM / SNS Pinpoint device token |
| `provider` | string | ✓ | `"fcm"` or `"sns"` |
| `platform` | string | ✓ | `"ios"` or `"android"` |

**Response**

```
204 No Content
```

---

### `DELETE /api/v1/mobile/push-token`

Remove the push token on logout.

**Response**

```
204 No Content
```

---

## 3. Inventory / Item Management

| Status | Method | Path | Description |
|:---:|---|---|---|
| 🔜 | `GET` | `/api/v1/items/{itemId}` | Get item details |
| 🔜 | `GET` | `/api/v1/items` | Search items (`q`, `category_id`, `limit`) |

### `GET /api/v1/items/{itemId}` — Response Schema

```json
{
  "id": "ITEM-001",
  "name": "Men's Jacket (Navy)",
  "description": "Description text (nullable)",
  "categoryId": "CAT-OUTERWEAR",
  "categoryName": "Outerwear (nullable)",
  "features": [
    {
      "code": "BLU-M",
      "colorCode": "BLU",
      "sizeCode": "M",
      "colorLabel": "Navy",
      "sizeLabel": "M (Medium)",
      "stockCount": 12,
      "shelfId": "SHELF-A-12"
    }
  ],
  "registeredAt": "2026-01-15T09:00:00Z",
  "updatedAt": "2026-04-01T14:30:00Z"
}
```

---

### `GET /api/v1/items` — Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `q` | string | Partial match on item name or ID |
| `category_id` | string | Filter by category ID |
| `limit` | integer | Max results (1–100, default 20) |

**Response**

```json
{ "data": [ /* array of Item */ ] }
```

---

## 4. Stock & Shelf Assignment Update ❌ New Request

Required for stock adjustments and shelf moves from the handheld terminal.

### `PATCH /api/v1/items/{itemId}/features/{featureCode}`

Partially update the stock count or shelf assignment of a specific item variation (colour × size).

**Request**

```json
{
  "stockCount": 15,
  "shelfId": "SHELF-B-03"
}
```

| Field | Type | Required | Description |
|---|---|:---:|---|
| `stockCount` | integer (≥0) | — | New stock count. Omit to leave unchanged |
| `shelfId` | string \| null | — | Shelf ID. Pass `null` to unassign from shelf |

**Response**

```json
{
  "code": "BLU-M",
  "colorCode": "BLU",
  "sizeCode": "M",
  "colorLabel": "Navy",
  "sizeLabel": "M (Medium)",
  "stockCount": 15,
  "shelfId": "SHELF-B-03"
}
```

**Errors**

| HTTP | SASO Code | Description |
|---|---|---|
| `400` | `SASO-ITEM-4001` | stockCount is negative |
| `404` | `SASO-ITEM-4040` | itemId not found |
| `404` | `SASO-ITEM-4041` | featureCode not found |
| `404` | `SASO-SHELF-4040` | Specified shelfId not found |

---

## 5. Categories

| Status | Method | Path | Description |
|:---:|---|---|---|
| 🔜 | `GET` | `/api/v1/categories` | Fetch nested category tree |

**Response**

```json
{
  "data": [
    {
      "id": "CAT-ROOT",
      "name": "All Categories",
      "parentId": null,
      "depth": 0,
      "children": [
        {
          "id": "CAT-OUTERWEAR",
          "name": "Outerwear",
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

## 6. Shelf Management

| Status | Method | Path | Description |
|:---:|---|---|---|
| 🔜 | `GET` | `/api/v1/shelves/{shelfId}` | Get shelf details |
| 🔜 | `GET` | `/api/v1/shelves/{shelfId}/items` | List items assigned to shelf |

---

## 7. Label Printing ❌ New Request

Called from Flutter when the `ff_label_print` feature flag is ON.  
Equivalent to the legacy API's `/shelf/outputPdf?id={id}`.

### `GET /api/v1/items/{itemId}/label`

Returns a PDF or ZPL label for an item.

**Query Parameters**

| Parameter | Type | Default | Description |
|---|---|---|---|
| `feature_code` | string | — | Restrict to a specific variation (omit for all) |
| `format` | string | `pdf` | `pdf` or `zpl` |

**Response**

```
200 OK
Content-Type: application/pdf          (format=pdf)
Content-Type: text/plain               (format=zpl)
Content-Disposition: attachment; filename="ITEM-001.pdf"

<binary or ZPL text>
```

---

### `GET /api/v1/shelves/{shelfId}/label`

Returns a shelf location label PDF (REST v1 equivalent of legacy `/shelf/outputPdf`).

**Query Parameters**

| Parameter | Type | Default | Description |
|---|---|---|---|
| `format` | string | `pdf` | `pdf` or `zpl` |

**Response**

```
200 OK
Content-Type: application/pdf
Content-Disposition: attachment; filename="SHELF-A-12.pdf"

<binary>
```

---

## 8. Config Bundle & Feature Flags

| Status | Method | Path | Description |
|:---:|---|---|---|
| ✅ | `GET` | `/api/v1/mobile/config` | Fetch offline config bundle |
| ✅ | `GET` | `/api/v1/feature-flags` | List all flags |
| ✅ | `POST` | `/api/v1/feature-flags` | Create flag |
| ✅ | `GET` | `/api/v1/feature-flags/{key}` | Get flag |
| ✅ | `PATCH` | `/api/v1/feature-flags/{key}` | Partially update flag |
| ✅ | `DELETE` | `/api/v1/feature-flags/{key}` | Delete flag |

### Config Bundle Response Schema

```json
{
  "version": "a3f2c1d8...",
  "generated_at": "2026-04-27T01:00:00Z",
  "feature_flags": [
    {
      "key": "ff_rest_api_v1",
      "description": "Enable REST API v1",
      "enabled": true,
      "rollout_percent": 100,
      "conditions": {}
    }
  ]
}
```

`version` is a SHA-256 hash of the bundle content. If it matches the previously stored value, the cached bundle can continue to be used without re-applying.

---

## 9. Meta

| Status | Method | Path | Description |
|:---:|---|---|---|
| ✅ | `GET` | `/api/v1/health` | Health check (no auth required) |
| ✅ | `GET` | `/api/v1/openapi.yaml` | OpenAPI spec download |

---

## Authentication (Common)

All authenticated endpoints require:

```
Authorization: Bearer <access_token>
Content-Type: application/json
Accept: application/json
```

| Item | Value |
|---|---|
| JWT algorithm | HS256 |
| Access token lifetime | 1 hour |
| Refresh token lifetime | ~1 year (rotation on every call) |
| Expired token response | `401 Unauthorized` |

---

## Error Format (RFC 7807)

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

`code` format: `SASO-{DOMAIN}-{4 digits}`

| Domain | Scope |
|---|---|
| `AUTH` | Authentication & authorisation |
| `ITEM` | Item operations |
| `SHELF` | Shelf operations |
| `LABEL` | Label printing |
| `PUSH` | Push notifications |
| `INSTALL` | Installation & configuration |
| `INFRA` | Infrastructure & server errors |

---

## Priority Summary

| Priority | Endpoint | Reason |
|:---:|---|---|
| **High** | Inventory, categories, shelves (🔜) | Core app features — basic operations blocked without these |
| **High** | `PUT /api/v1/mobile/push-token` | Push notifications incomplete without token registration |
| **Medium** | `PATCH /api/v1/items/{itemId}/features/{featureCode}` | Stock adjustment & shelf move operations |
| **Low** | Label printing (`/label`) | Controlled by `ff_label_print` flag — can wait until post-launch |

---

*This document corresponds to the full schema definitions in [openapi.yaml](openapi.yaml).*  
*Last updated: 2026-04-27*
