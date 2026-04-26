# REST API v1 Reference

Reference for the REST API v1 (`/api/v1/*`) shipped with SASO M3.
The Flutter app uses these endpoints when the `ff_rest_api_v1` feature flag is ON.

!!! info "Authentication"
    All endpoints require a Bearer JWT (RS256, 15 min validity).
    The mobile app retrieves and stores the token from the server settings page.

!!! warning "Status"
    M3 has not shipped yet, so this reference is a **design-time** snapshot.
    If the implementation in [rest_api_client.dart](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/blob/main/lib/data/datasources/remote/v1/rest_api_client.dart) disagrees, the implementation wins.

[Download the OpenAPI 3.0 spec (openapi.yaml)](openapi.yaml){ download="saso-rest-api-v1.openapi.yaml" } and import it into Postman / Insomnia / OpenAPI Generator.

---

## Base URL

| Environment | URL |
|---|---|
| Staging | `https://staging.api.example.com` |
| Production | `https://api.example.com` |

Every request must include `Authorization: Bearer <JWT>`.
Responses are `application/json`; errors use [RFC 7807 Problem Details](https://datatracker.ietf.org/doc/html/rfc7807) (`application/problem+json`).

---

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | [`/api/v1/items/{itemId}`](#get-itemsitemid) | Get item details |
| GET | [`/api/v1/items`](#get-items) | Search items |
| GET | [`/api/v1/categories`](#get-categories) | Category tree |
| GET | [`/api/v1/shelves/{shelfId}`](#get-shelvesshelfid) | Get shelf details |
| GET | [`/api/v1/shelves/{shelfId}/items`](#get-shelvesshelfiditems) | Items on a shelf |

---

## GET /items/{itemId}

Fetch a single item by ID.

**Path parameters**

| Name | Type | Required | Description |
|---|---|:---:|---|
| `itemId` | string | ✓ | Internal item ID (e.g. `ITEM-001`) |

**Example request**

```http
GET /api/v1/items/ITEM-001 HTTP/1.1
Host: api.example.com
Authorization: Bearer <JWT>
Accept: application/json
```

**Response (200 OK)**

```json
{
  "id": "ITEM-001",
  "name": "Men's jacket (navy)",
  "description": null,
  "categoryId": "CAT-OUTERWEAR",
  "categoryName": "Outerwear",
  "features": [
    {
      "code": "BLU-M",
      "colorCode": "BLU",
      "sizeCode": "M",
      "colorLabel": "Navy",
      "sizeLabel": "M",
      "stockCount": 12,
      "shelfId": "SHELF-A-12"
    }
  ],
  "registeredAt": "2024-04-01T09:00:00Z",
  "updatedAt": "2024-04-15T17:30:00Z"
}
```

**Errors**

| Status | Code | Meaning |
|---|---|---|
| 401 | `SASO-DOMAIN-401` | Auth failure (invalid/expired JWT) |
| 404 | `SASO-DOMAIN-1042` | Item ID does not exist |
| 5xx | `SASO-DOMAIN-5xx` | Server-side error |

---

## GET /items

Search items.

**Query parameters**

| Name | Type | Required | Description |
|---|---|:---:|---|
| `q` | string |  | Item name / ID partial match |
| `category_id` | string |  | Filter by category |
| `limit` | integer |  | Max results (1–100, default 20) |

**Example request**

```http
GET /api/v1/items?q=jacket&category_id=CAT-OUTERWEAR&limit=20 HTTP/1.1
Host: api.example.com
Authorization: Bearer <JWT>
```

**Response (200 OK)**

```json
{
  "data": [
    {
      "id": "ITEM-001",
      "name": "Men's jacket (navy)",
      "categoryId": "CAT-OUTERWEAR",
      "features": [],
      "registeredAt": "2024-04-01T09:00:00Z"
    }
  ]
}
```

---

## GET /categories

Returns the full category tree starting from roots.

**Example request**

```http
GET /api/v1/categories HTTP/1.1
Host: api.example.com
Authorization: Bearer <JWT>
```

**Response (200 OK)**

```json
{
  "data": [
    {
      "id": "CAT-OUTERWEAR",
      "name": "Outerwear",
      "parentId": null,
      "depth": 0,
      "children": [
        {
          "id": "CAT-JACKET",
          "name": "Jackets",
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

Get shelf details. `itemIds` lists the items currently registered to the shelf.

**Path parameters**

| Name | Type | Required | Description |
|---|---|:---:|---|
| `shelfId` | string | ✓ | Shelf ID (e.g. `SHELF-A-12`) |

**Response (200 OK)**

```json
{
  "id": "SHELF-A-12",
  "label": "Warehouse A, Shelf 12",
  "location": "Floor 1, Aisle A",
  "itemIds": ["ITEM-001", "ITEM-002"]
}
```

---

## GET /shelves/{shelfId}/items

Bulk-fetch items registered on a shelf.

**Response (200 OK)**

```json
{
  "data": [
    {
      "id": "ITEM-001",
      "name": "Men's jacket",
      "categoryId": "CAT-OUTERWEAR",
      "features": [],
      "registeredAt": "2024-04-01T09:00:00Z"
    }
  ]
}
```

---

## Schemas

### Item

| Field | Type | Required | Description |
|---|---|:---:|---|
| `id` | string | ✓ | Item ID |
| `name` | string | ✓ | Display name |
| `description` | string |  | Description |
| `categoryId` | string | ✓ | Category ID |
| `categoryName` | string |  | Category name (denormalized) |
| `features` | Feature[] |  | Color × size variants (default `[]`) |
| `registeredAt` | string (date-time) | ✓ | Registration timestamp (ISO 8601) |
| `updatedAt` | string (date-time) |  | Last update timestamp |

### Feature

| Field | Type | Required | Description |
|---|---|:---:|---|
| `code` | string | ✓ | Color/size code (e.g. `BLU-M`) |
| `colorCode` | string | ✓ | Color code |
| `sizeCode` | string | ✓ | Size code |
| `colorLabel` | string |  | Display name for color |
| `sizeLabel` | string |  | Display name for size |
| `stockCount` | integer |  | Stock count (default `0`) |
| `shelfId` | string |  | Shelf ID |

### Category

| Field | Type | Required | Description |
|---|---|:---:|---|
| `id` | string | ✓ | Category ID |
| `name` | string | ✓ | Display name |
| `parentId` | string |  | Parent category ID (`null` for roots) |
| `children` | Category[] |  | Child categories (default `[]`) |
| `depth` | integer |  | Tree depth (root is 0) |

### Shelf

| Field | Type | Required | Description |
|---|---|:---:|---|
| `id` | string | ✓ | Shelf ID |
| `label` | string |  | Shelf label |
| `location` | string |  | Physical location |
| `itemIds` | string[] |  | Registered item IDs (default `[]`) |

### ProblemDetails (error response)

[RFC 7807](https://datatracker.ietf.org/doc/html/rfc7807) compliant + SASO domain code.

| Field | Type | Required | Description |
|---|---|:---:|---|
| `type` | string (URI) | ✓ | URI identifying the problem type |
| `title` | string | ✓ | Short summary |
| `status` | integer | ✓ | HTTP status code |
| `detail` | string |  | Detailed message |
| `instance` | string (URI) |  | URI of the failing instance |
| `code` | string |  | SASO domain code (`SASO-DOMAIN-NNNN`) |

Example error response:

```json
{
  "type": "https://saso.example.com/errors/item-not-found",
  "title": "Item not found",
  "status": 404,
  "detail": "Item with id ITEM-999 does not exist",
  "code": "SASO-DOMAIN-1042"
}
```
