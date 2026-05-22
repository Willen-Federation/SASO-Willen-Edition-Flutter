# SASO Flutter ↔ Legacy Backend Integration Coverage

This document maps each backend endpoint exposed by the SASO PHP server
(`SASO-Willen-Edition` repo) to its Flutter-side caller (or marks it
out-of-scope for the mobile client). It is the source of truth used to verify
that mobile↔server integration is "もれなく" — no in-scope endpoint is left
unwired and no out-of-scope endpoint is silently shipped.

Last refreshed: 2026-05-23 (REST v1 + legacy session-cookie endpoints, after
PR-93 follow-up that filled the editing / logout / storage-locations gaps).

## REST v1 (`/api/v1/*`) — the mobile contract

| # | Endpoint | Purpose | Flutter caller | Status |
|---|---|---|---|---|
| 1 | `GET /api/v1/health` | Liveness probe | `ConnectionTester.autoDetect`, `RestV1ApiClient.health` | ✅ |
| 2 | `GET /api/v1/auth/providers` | Discovery: enabled login methods | `AuthDiscoveryService.discover` | ✅ |
| 3 | `POST /api/v1/mobile/connect` | QR pairing → JWT pair | `RestV1ApiClient.connectWithPairingToken` (from `LoginPage`/`QrPairingPage`) | ✅ |
| 4 | `POST /api/v1/mobile/token/refresh` | Rotate access token | `RestV1ApiClient.refreshAccessToken` (auto 401 retry) | ✅ |
| 5 | `GET /api/v1/mobile/config` | Offline config + feature flag bundle | `ConfigBundleSyncProvider` | ✅ |
| 6 | `GET /api/v1/items` | Search/list items | `RestV1ApiClient.searchItems` → `ItemSearchPage` | ✅ |
| 7 | `GET /api/v1/items/{id}` | Item detail | `RestV1ApiClient.fetchItem` → `ItemDetailPage` | ✅ |
| 8 | `POST /api/v1/items` | Create item | `RestV1ApiClient.createItem` → `ItemRegisterPage` (offline-queued via outbox) | ✅ |
| 9 | `PATCH /api/v1/items/{id}` | Update item (status / fields) | `RestV1ApiClient.updateItem` → `ItemStatusUpdater` + new `ItemFieldUpdater` (`ItemEditPage`) | ✅ |
| 10 | `POST /api/v1/items/drafts` | Multipart image upload for AI enrichment | `RestV1ApiClient.createItemDraftWithAi` → `ItemRegisterPage` | ✅ |
| 11 | `GET /api/v1/categories` | List categories | `RestV1ApiClient.fetchCategories` → `CategoryBrowserPage`, `_CategoryPickerTile` | ✅ |
| 12 | `GET /api/v1/storage-locations` | List root / children | `RestV1ApiClient.fetchStorageLocations` (REST fallback for MCP `list_storage_locations`) → `LocationListPage` | ✅ |
| 13 | `GET /api/v1/storage-locations/{id}` | Shelf metadata | `RestV1ApiClient.fetchShelf` → `ShelfViewPage` | ✅ |
| 14 | `GET /api/v1/storage-locations/{id}/items` | Items on shelf | `RestV1ApiClient.fetchItemsByShelf` → `ShelfViewPage` | ✅ |
| 15 | `GET /api/v1/barcode/{code}` | JAN/EAN/ISBN lookup → item summary | `RestV1ApiClient.lookupBarcode` → `BarcodeScannerPage` | ✅ |
| 16 | `GET / POST / PATCH / DELETE /api/v1/feature-flags[/{key}]` | Operator-only CRUD | `RestV1ApiClient.{fetch,create,update,delete}FeatureFlag` (kept for parity; no in-app admin UI) | 🔵 Operator-only |
| 17 | `GET /api/v1/openapi.yaml`, `GET /api/v1/docs` | Static spec / Swagger UI | n/a | ⚪ Out of scope (developer doc) |
| 18 | `POST /mcp` (JSON-RPC) | MCP dispatcher | `McpClient.callTool` → `mcpItemSearchProvider`, `storageLocationsProvider`, `registerItem`, `adjustStock` | ✅ |
| 19 | `POST /api/v1/mobile/pairing-codes` | Admin-side QR generation | n/a | ⚪ Admin web `/mypage/devicePair` |
| 20 | `GET / DELETE /api/v1/mobile/tokens[/{id}]` | Admin device-token audit | n/a | ⚪ Admin web `/mypage/devicePair` |

## Legacy session-cookie endpoints (`/auth/*`, `/category/list.json`)

| # | Endpoint | Purpose | Flutter caller | Status |
|---|---|---|---|---|
| 21 | `POST /auth/start` | Username/password login → `Set-Cookie` | `LegacyAuthService.login` → `LoginPage` (when discovery indicates legacy) | ✅ |
| 22 | `/auth/logout` | Session invalidation | `LegacyAuthService.logout` (clears local cookie; relies on server expiry) | ✅ (local) |
| 23 | `GET /category/list.json` | Categories under session cookie | `LegacyApiClient.fetchCategories` + `ConnectionTester` legacy probe | ✅ |
| 24 | `GET /item/start` | Item detail under session cookie | `LegacyApiClient.fetchItem` | ✅ |
| 25 | `GET /shelf/outputPdf` (metadata parse) | Shelf metadata under session cookie | `LegacyApiClient.fetchShelf` | ✅ |
| 26 | `POST /api/v1/items` (create), `PATCH /api/v1/items/{id}` | Legacy mode lacks these — calls `UnsupportedError` | `LegacyApiClient.{createItem,updateItem}` (intentional throw) | 🔵 REST-only feature |

## Web-rendered features not ported to mobile

These remain on the PHP server, reachable from the in-app `/mypage` link
(opened in the system browser by `ServerSettingsPage._openMyPage`).

| Endpoint family | Reason out of scope |
|---|---|
| `/label/*` (PDF label printing) | Desktop-only printing workflow |
| `/member/*`, `/role/*`, `/admin/*` | Admin-only; staff log in via web |
| `/itemAttribute/*` | EAV admin |
| `/scanStock/start` | Superseded by `/scanner?mode=inventory` |
| `/verify/start`, `/verify/create` | Email/phone verification (web-only) |
| `/search/start` | Web global search; mobile uses `/items` REST |
| `/mypage/passkeyBegin/Complete/Delete` | Passkey enrolment (web WebAuthn) |
| `/mypage/devicePair`, `/mypage/deviceRevoke` | Device-token admin (web) |
| `/mypage/editProfile`, `/mypage/unlinkProvider` | Profile management |
| `/archive/list` | Archived-items listing |
| `/barcode/printSheet` | Bulk barcode sheet PDF |
| `/webhook`, `/webhock` | Server git-pull webhook |

## Auth flows surveyed

| Mode | Mechanism | Flutter file |
|---|---|---|
| Mock | No auth | `auth_state_provider.dart` mock branch |
| Legacy | `POST /auth/start` → session cookie | `legacy_auth_service.dart` |
| REST v1 — username/password | `POST /auth/start` then upgrade if local provider exists | discovered via `AuthDiscoveryService` |
| REST v1 — QR pairing | `POST /api/v1/mobile/connect` | `qr_pairing_page.dart`, `LoginPage._loginWithManualToken` |
| OIDC | `flutter_appauth` | `oidc_auth_service.dart` |
| Auth0 | `auth0_flutter` | `auth0_auth_service.dart` |
| SAML | WebView fallback | `saml_auth_service.dart`, `saml_webview_page.dart` |
| Firebase | `firebase_auth` | `firebase_auth_service.dart` |
| Cognito | Amplify Auth | `cognito_auth_service.dart` |

## Verification commands

```bash
# 1. Confirm REST v1 is available on the production server.
curl -i https://saso.sksl.jp/api/v1/health

# 2. Confirm legacy fallback responds.
curl -i https://saso.sksl.jp/category/list.json

# 3. Confirm the Flutter app picks the right ApiMode.
make run-ios   # then observe `[AuthDiscovery]` log lines in `flutter logs`.
```

## Known production-server quirks (2026-05-22 sweep)

- `GET /api/v1/auth/providers` returns HTTP 500 (`SASO-INFRA-9000`).
  The discovery service falls back to `ServerAuthDiscovery.localOnly` so the
  login page still renders. Fix is server-side; the mobile client is robust.
- `GET /api/v1/items` returns HTTP 500 when called without auth instead of the
  expected 401. The Flutter client never sends this path unauthenticated, so
  this does not affect the app, but is worth tracking server-side.
