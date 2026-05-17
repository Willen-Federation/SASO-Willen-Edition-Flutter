# 2026-05-17 Medium-Severity Security Audit — Closure Summary

Tracker: [Willen-Federation/SASO-Willen-Edition-Flutter#26][issue]. Source
audit: `security-audit-report-2026-05-17.md`.

All 10 findings landed as separate PRs ahead of this consolidation
document. This page records what shipped, where it lives, and the
operational follow-ups that are still open after closure.

[issue]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/26

## Status

| ID      | Layer            | PR                                                                                      | Status   |
| ------- | ---------------- | --------------------------------------------------------------------------------------- | -------- |
| MED-001 | Mobile (Flutter) | [#58](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/58)         | Shipped  |
| MED-002 | Mobile (Android) | [#59](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/59)         | Shipped  |
| MED-003 | Mobile (Android) | [#60](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/60)         | Shipped  |
| MED-004 | CI/CD            | [#64](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/64) (+[#82](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/82)) | Shipped  |
| MED-005 | CI/CD            | [#64](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/64)         | Shipped  |
| MED-006 | Supply chain     | [#56](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/56)         | Shipped  |
| MED-007 | CI/CD            | [#61](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/61)         | Shipped  |
| MED-008 | Mobile (iOS)     | [#62](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/62)         | Shipped  |
| MED-009 | Process          | [#64](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/64)         | Shipped  |
| MED-010 | Web              | [#63](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/63)         | Shipped  |

## What shipped

### MED-001 — SAML WebView host validation ([#58][med-001])

`lib/presentation/pages/auth/saml_webview_page.dart` runs every candidate
`loginUrl` through `UrlValidator.ensureHttpsOrLoopback` and caches the
resulting origin as the `_trustedOrigin`. The `NavigationDelegate` then
rejects any cross-origin navigation. The previous code accepted any
URL with the registered scheme; an open-redirect or cross-frame trick
inside the IdP page could have driven the WebView to a callback URL
bearing an attacker-controlled JWT.

[med-001]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/58

### MED-002 — Android `CallbackActivity` hardening ([#59][med-002])

`android/app/src/main/AndroidManifest.xml` now declares the
`flutter_web_auth_2` callback activity with `taskAffinity=""`,
`launchMode="singleTask"`, `excludeFromRecents="true"`, and a host +
path pin on the intent filter so unrelated `jp.willen.saso://` deep
links no longer match.

[med-002]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/59

### MED-003 — Android backup channels disabled ([#60][med-003])

The same manifest now sets `allowBackup="false"`,
`fullBackupContent="false"`, and `dataExtractionRules=
"@xml/data_extraction_rules"`. The new
`android/app/src/main/res/xml/data_extraction_rules.xml` excludes the
`flutter_secure_storage` `EncryptedSharedPreferences` blob and the
local SQLite caches from cloud backup and device-to-device transfer on
Android 12+.

[med-003]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/60

### MED-004 — Third-party GitHub Actions SHA-pinned ([#64][med-004] + [#82][med-004b])

`.github/workflows/flutter_ci.yml` and `.github/workflows/docs.yml`
pin every third-party action to a 40-character commit SHA with a
`# vX.Y.Z` comment alongside (`actions/checkout`,
`actions/setup-python`, `subosito/flutter-action`,
`codecov/codecov-action`). [#82][med-004b] re-pinned `codecov-action`
to the correct SHA for v4.6.0 after an initial mismatch.

[med-004]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/64
[med-004b]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/82

### MED-005 — Workflow-level least-privilege `GITHUB_TOKEN` ([#64][med-005])

`flutter_ci.yml` declares a workflow-level `permissions: contents:
read`. The unit-test job elevates locally to `id-token: write` for
codecov OIDC; every other job stays read-only.

[med-005]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/64

### MED-006 — `pubspec.lock` tracked + enforced ([#56][med-006])

`.gitignore` keeps `*.lock` in general but un-ignores `pubspec.lock`
specifically. CI steps invoke `flutter pub get --enforce-lockfile`, so
the build fails closed if the lockfile is missing or disagrees with
`pubspec.yaml`.

[med-006]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/56

### MED-007 — `mkdocs.yml` PyYAML tags removed ([#61][med-007])

`mkdocs.yml` now declares `emoji_index:
material.extensions.emoji:twemoji` and the matching `emoji_generator`
in the colon-delimited string form that mkdocs-material 9.6+ resolves
through its own safe-load constructor. The `!!python/name:` tags that
required `yaml.unsafe_load` semantics are gone — the docs deploy
parses cleanly under `yaml.safe_load`.

[med-007]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/61

### MED-008 — iOS `Runner.entitlements` ([#62][med-008])

`ios/Runner/Runner.entitlements` ships with `aps-environment =
development` and `com.apple.developer.associated-domains` pointing at
`applinks:auth.willen.jp`. The Xcode project file wires
`CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements` on all three
Runner build configurations. `AppDelegate.swift`'s
`registerForRemoteNotifications()` now lands a real APNs token in dev
/ TestFlight builds; production swaps to `production` via Xcode build
settings on archive.

[med-008]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/62

### MED-009 — Dependabot + CODEOWNERS ([#64][med-009])

`.github/dependabot.yml` configures weekly updates across `pub`,
`github-actions`, and `pip` ecosystems. `.github/CODEOWNERS` requires
a maintainer review on every path that touches the auth surface,
mobile platform signing, manifest privileges, CI workflows, and
dependency resolution.

[med-009]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/64

### MED-010 — Web Content-Security-Policy ([#63][med-010])

`web/index.html` ships a Flutter-web-tuned CSP meta tag covering
`script-src 'self' 'wasm-unsafe-eval'` (CanvasKit / Skwasm),
`connect-src 'self' https:`, `frame-ancestors 'none'` (clickjacking),
`object-src 'none'`, `base-uri 'self'`, and `form-action 'self'`.

[med-010]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/pull/63

## Open follow-ups

These items were called out either in the audit's "Future work" notes
or surfaced during the per-finding PRs. They are intentionally out of
scope for issue #26 and tracked separately.

- **SAML JWT signature verification** — `SamlAuthService.completeWithToken`
  still stores the token without validating the IdP signature. Tracked
  separately because it needs an agreed-upon JWKS endpoint and key
  rotation policy.
- **Android SPKI pin-set** — `network_security_config.xml` keeps a
  `TODO(team)` for `<pin-set>` entries once `auth.willen.jp`'s primary
  + backup SPKI hashes are decided. Pairs with #27.
- **iOS AASA file at the IdP host** — `Runner.entitlements` declares
  `applinks:auth.willen.jp`, but until the IdP publishes
  `/.well-known/apple-app-site-association` for the app's Team ID +
  bundle identifier, Universal Link callbacks fall back to the custom
  `jp.willen.saso://` scheme.
- **`CODEOWNERS` team handle** — the file currently lists the long-term
  maintainer (`@kackey621`) as the fallback reviewer. Once
  `@willen-federation/security-reviewers` is provisioned in org admin,
  replace the maintainer handle on the security-sensitive paths.
- **`Permissions-Policy` + `Strict-Transport-Security` at the edge** —
  the CSP meta tag is the floor; HTTP-header equivalents still need to
  be set at the Netlify / nginx layer that fronts `web/`.
