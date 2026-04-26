# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 0.x (development) | Yes |

## Reporting a Vulnerability

**Do not open a public GitHub Issue for security vulnerabilities.**

Please report security issues by email to the maintainers. Include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested mitigations

We will acknowledge receipt within 48 hours and aim to release a patch within 14 days for critical issues.

## Security Design

### Credential Storage

| Credential | Storage |
|---|---|
| JWT access token | `flutter_secure_storage` (iOS Keychain / Android Keystore) |
| Refresh token | `flutter_secure_storage` |
| Session cookie | `flutter_secure_storage` |
| FCM device token | In-memory only (re-acquired on launch) |

**Never** store tokens as plaintext in `SharedPreferences`, SQLite, or files.

### Network

- HTTPS only in production; HTTP is blocked by ATS (iOS) and Network Security Config (Android)
- Certificate pinning is planned for v1.0 (`ff_cert_pin` flag)
- All API requests include a `User-Agent` header identifying the app version

### Firebase

- `GoogleService-Info.plist` and `google-services.json` must **never** be committed to version control
- Firebase API keys in these files are client-side identifiers protected by App Check in production
- Remote Config values are treated as untrusted input and validated before use

### Feature Flags

- Feature flag values from Remote Config are validated against the expected type before use
- Debug builds override all flags to `true`; this code path must never reach production builds
- Flag values cannot grant elevated permissions — they only enable UI/network features

### Data at Rest

- The SQLite cache (`items`, `categories`, `shelves`) contains non-sensitive inventory data
- No PII is stored on-device
- Cache can be cleared via `DatabaseHelper.clearAll()`

### Dependencies

Dependencies are pinned in `pubspec.lock`. Run `flutter pub outdated` regularly and update dependencies with known CVEs promptly.
