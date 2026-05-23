# v3.0 Migration — Legacy Auth Removal Plan

## Status

| Version | What lands |
|---|---|
| **v2.5** (current) | Deprecation infrastructure: `ApiMode.legacy` is `@Deprecated`, settings UI demotes it to a collapsed "Compatibility mode (deprecated)" section, REST credential flow (`RestAuthService` + server `/api/v1/auth/login`) is the recommended path. Legacy code paths remain functional. |
| **v3.0** (target) | `ApiMode.legacy`, `LegacyApiClient`, `LegacyAuthService`, `ServerConfig.sessionCookie`, and every `TODO(v3.0)` site listed below are deleted in a single milestone PR. |

## Phase C-light (this document)

Phase C as originally scoped called for "removing the 14 `ApiMode.legacy` branching sites." Removing them outright in v2.5 would break users still on legacy SASO deployments — so this PR instead **instruments** every site for deletion in v3.0:

1. **`TODO(v3.0)` markers** at each call site that touches `ApiMode.legacy`, `LegacyApiClient`, `LegacyAuthService`, or `ServerConfig.sessionCookie`. Each marker names the matching deletion point so v3.0 work is a mechanical sweep, not an investigation.
2. **`deprecated_member_use_from_same_package: info`** in `analysis_options.yaml` — every existing site has a matching `// ignore` comment; any *new* use lights up in analyzer output.

## v3.0 deletion checklist

Search the codebase for `TODO(v3.0)` to surface all sites in current form. As of this PR they are:

### Routing dispatch (4 sites — these are the original "14 branches" minus the mock-only checks)

| File | What v3.0 does |
|---|---|
| `lib/presentation/providers/api_client_provider.dart` | Drop the `ApiMode.legacy => LegacyApiClient(...)` arm; the switch becomes `mock`/`rest` only |
| `lib/presentation/providers/category_provider.dart` | Same: drop the legacy arm in the inline switch |
| `lib/presentation/pages/shelf/shelf_view_page.dart` | Same |
| `lib/core/network/connection_tester.dart` | Drop the legacy fallback probe + the `_probeUri` legacy arm + the `_headers` legacy cookie arm. `autoDetect()` simplifies to "try REST, return the result." |

### Auth dispatch

| File | What v3.0 does |
|---|---|
| `lib/presentation/providers/auth_state_provider.dart` (authService provider) | Collapse to a one-liner: `return RestAuthService(secureStorage);`. Drop the `ApiMode.rest` check |
| `lib/presentation/providers/auth_state_provider.dart` (loadStoredCredentials) | Drop the `sessionCookieKey` read branch entirely |

### Data model

| File | What v3.0 does |
|---|---|
| `lib/presentation/providers/server_config_provider.dart` | Drop the `ApiMode.legacy` enum value. Drop `ServerConfig.sessionCookie` field. Drop `updateSessionCookie()` helper |
| `lib/core/constants/app_constants.dart` | Remove `sessionCookieKey` constant (if not referenced elsewhere) |

### File deletions

| File | Why |
|---|---|
| `lib/data/datasources/remote/legacy/legacy_api_client.dart` | No remaining callers after the 4 dispatch sites above are simplified |
| `lib/core/auth/providers/legacy_auth_service.dart` | No remaining callers after the authService provider is collapsed |

### UI cleanup

| File | What v3.0 does |
|---|---|
| `lib/presentation/pages/settings/server_settings_page.dart` | Delete `_LegacyDeprecationBanner` widget. Delete the "Compatibility mode (deprecated)" `ExpansionTile`. The mode chooser becomes mock + rest only. Delete `apiModeLegacy*` strings from `app_en.arb` / `app_ja.arb` and regenerate l10n |

### Test cleanup

| File | What v3.0 does |
|---|---|
| `test/unit/core/auth/providers/legacy_auth_service_test.dart` | Delete entirely |
| `test/widget/pages/settings/server_settings_page_test.dart` | Drop the legacy-mode test cases (banner / expansion tile / radio); keep the mock + rest cases |
| Any other `// ignore: deprecated_member_use_from_same_package` from this PR | Remove the ignore comments along with their target lines |

## Why we kept legacy in v2.5

Some SASO deployments in the wild are still on the legacy code base without the REST v1 surface (`/api/v1/health` returns 404, `/auth/start/` is the only login endpoint). Forcing those users onto REST in v2.5 would break their app overnight. v2.5 ships:

- A clear deprecation signal (UI banner, `@Deprecated` annotation, settings demotion)
- A working REST replacement path so any user whose server *does* support REST can opt in immediately
- The `tools/repair-app-key.php` and installer security-step changes server-side so new REST deployments boot with valid secrets

v3.0 is the cliff: legacy users must upgrade their server to REST v1 before they can install v3.0 of the mobile app.

## Pairs with server-side

- **PR-A1 #237** — `repair-app-key.php` + `EnvWriter` (merged)
- **PR-A2 #238** — installer security step auto-generates APP_KEY/JWT_SECRET/WEBHOOK_SECRET on fresh installs (merged)
- **PR-A3 #239** — REST `/api/v1/auth/login` + `/logout` + `/password` (open)
- **PR-B1 #115** — `AuthDiscoveryOutcome` surfaces `serverMisconfigured` (merged)
- **PR-B2 #116** — `ApiMode.legacy` `@Deprecated` + UI demotion (merged)
- **PR-B3 #117** — `RestAuthService` for REST username/password (merged)

## Production deployment

The current `saso.sksl.jp` deployment is still serving the pre-A1/A2 codebase and is missing `APP_KEY` in its `.env` (returns 500 `SASO-INFRA-9000` from `/api/v1/auth/providers`). Either of these unblocks it:

- **Quick path** (no deploy): ops appends `APP_KEY=$(openssl rand -base64 32)` + `JWT_SECRET=$(openssl rand -base64 32)` to `.env`, `chmod 0600`, reload PHP-FPM.
- **Proper path**: deploy server main (HEAD `139eabd`), run `php tools/repair-app-key.php`, reload PHP-FPM.

Once `/api/v1/auth/providers` returns 200, the Flutter client can hit the merged REST auth flow end-to-end.
