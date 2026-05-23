# Privacy Policy

Last updated: 2026-05-24
Effective date: 2026-05-24

Willen Federation ("we", "us") publishes the mobile application **SASO Willen Edition** (Android and iOS, the "App") and sets out below the policy ("Policy") governing how the App handles personal information of its users.

This Policy is designed to satisfy both Google Play and Apple App Store requirements, and a single common text is shared between the Android (Issue #142) and iOS (Issue #122) builds.

---

## 1. Operator

| Item | Value |
|---|---|
| Operator | Willen Federation |
| App name | SASO Willen Edition |
| Platforms | Android (Google Play) / iOS (App Store) |
| Distribution model | Self-hosted client that connects to a SASO server operated by each tenant organisation |
| Contact | `https://github.com/willen-federation/saso-willen-edition-flutter/issues` |

---

## 2. Scope

The App is a client terminal that connects to a **SASO warehouse inventory management server** and lets warehouse workers perform stock lookups, barcode scans, and shelf management from a smartphone.

- The **tenant organisation** that operates the connected SASO server is responsible for storing and processing business data (including any personal data) on that server.
- The App itself stores only the minimum cache and authentication material required on the device.
- This Policy covers "information handled on the device by the App". The processing of data stored on each tenant's SASO server is governed by that tenant's own privacy policy.

---

## 3. Information We Collect

The App collects and processes the following information.

### 3.1 Authentication material

| Type | Description | Storage |
|---|---|---|
| Username / password | Sent to the server at sign-in time. **Not stored on the device.** | (Not stored) |
| JWT access / refresh tokens | Used for API authentication in REST mode. | Device secure storage (Keychain / Keystore) |
| Session cookie | Used for API authentication in legacy mode. | Device secure storage (encrypted) |
| Pairing token | Short-lived token issued during QR pairing. | In memory only (not persisted) |

### 3.2 SAML / SSO attributes

When you sign in via SSO (SAML / OIDC), the identity provider returns:

- Display name
- Email address
- Department / role (depends on IdP configuration)
- Group memberships (depends on IdP configuration)

These attributes are **bound to a session held by the server**; the device stores only the session identifier.

### 3.3 Device / push notification data

| Type | Purpose |
|---|---|
| FCM registration token (Android) | Push notification routing |
| APNs device token (iOS) | Push notification routing |
| Amazon SNS endpoint ARN | Auxiliary push routing identifier |
| Device ID (UUID generated at install time) | Identification of paired devices |
| OS version / app version | Compatibility check, error analysis |

### 3.4 Usage / diagnostic data

| Type | Purpose |
|---|---|
| Error logs (crash and exception stack traces) | Incident analysis and quality improvement |
| API request timestamps and status codes | Connection diagnostics and audit |
| Barcode scan history (local) | UX improvement and offline queue processing |

Error logs are designed not to include authentication secrets (raw passwords or raw JWTs).

### 3.5 Camera and photo / media

| Use case | Source | Transmitted off-device |
|---|---|---|
| Barcode scan | Camera frames | **Not transmitted** (decoded on-device only) |
| Optional product / shelf photo upload | Photo library selection | Only images that the user explicitly uploads are sent to the SASO server |

The App does not record or persist raw camera frames.

---

## 4. Purposes of Processing

We use the collected information only for the following purposes.

1. User authentication and session management against the SASO server
2. Display and update of business data (inventory, categories, shelves)
3. Operation queuing while offline and re-sync on reconnection
4. Push notification delivery
5. Incident analysis, security audit, and quality improvement
6. Compliance with applicable laws and platform policies (Google Play, App Store, Japan APPI, EU GDPR, etc.)

We do **not** use the data for advertising, behavioural profiling, or sale to third parties.

---

## 5. Third-Party Services / Sub-processors

The App communicates with the following third-party services. Each service is governed by its own provider's terms.

| Service | Provider | Purpose | Data shared |
|---|---|---|---|
| Firebase Cloud Messaging (FCM) | Google LLC | Push delivery on Android | FCM registration token, part of notification payload |
| Apple Push Notification service (APNs) | Apple Inc. | Push delivery on iOS | APNs device token, part of notification payload |
| Amazon SNS / Pinpoint | Amazon Web Services, Inc. | Auxiliary push routing and endpoint management | Device tokens, endpoint ARN |
| Auth0 | Okta, Inc. | OIDC / SSO authentication (only if the tenant uses Auth0) | User identifier, authentication attributes |
| Netlify | Netlify, Inc. | Hosting of this Privacy Policy site | Visitor IP address (standard access log) |
| Sentry (optional) | Functional Software, Inc. | Crash reporting (only if the tenant enables it) | Stack traces, app version, OS version |

Business data (inventory, SAML attributes, business events) is **never sent anywhere other than the SASO server operated by your tenant**.

---

## 6. Retention

| Data | Retention period |
|---|---|
| JWT access token | Until expiry (up to 1 hour) or logout |
| JWT refresh token | Until expiry (up to 30 days) or logout |
| Session cookie | Until server-side session expires |
| FCM / APNs token | Until uninstall or OS revocation |
| Offline queue | Until successful upload or manual deletion |
| Local cache (inventory, categories) | Until cache clear or uninstall |
| All authentication material | Deleted on logout |

---

## 7. Your Rights

You have the following rights. GDPR-protected residents have equivalent rights.

1. **Access**: request disclosure of information the App holds on your device.
2. **Rectification**: correct inaccurate information.
3. **Erasure**: log out and uninstall the App — this removes all personal information stored on the device.
4. **Opt-out / withdrawal**: opt out of push notifications and revoke camera or photo permissions in your OS settings at any time.
5. **Portability**: data held on the SASO server itself should be requested from your tenant organisation.

Requests can be raised via GitHub Issues or via your tenant administrator.

---

## 8. Children

The App is intended for **business use** and is **not directed to children under 13**. If we become aware that we have inadvertently collected data from a child, we will delete it.

---

## 9. Security

- Credentials are stored in OS-provided secure storage (Android Keystore / iOS Keychain).
- All server communication requires HTTPS (TLS 1.2 or later).
- Offline queues are persisted in an encrypted SQLite store.
- For vulnerability reports, please follow the procedure in [SECURITY.md](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/SECURITY.md).

---

## 10. Changes to This Policy

This Policy may change without prior notice in response to legal amendments, feature changes, or addition of third-party services. Material changes will be announced via in-app notice, by updating the "Last updated" date above, and through GitHub release notes.

---

## 11. Contact

| Topic | Contact |
|---|---|
| General privacy enquiries | [GitHub Issues](https://github.com/willen-federation/saso-willen-edition-flutter/issues) |
| Security vulnerability reports | Follow [SECURITY.md](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/SECURITY.md) |
| Business data requests | The tenant organisation operating the connected SASO server |

---

## Related links

- [日本語版](../../legal/privacy-policy/)
- [Google Play privacy policy requirements](https://support.google.com/googleplay/android-developer/answer/9859455)
- [App Store app privacy details](https://developer.apple.com/app-store/app-privacy-details/)
