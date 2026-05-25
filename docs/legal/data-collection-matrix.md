# Data Collection Matrix — Play Console Data Safety & App Privacy

> Source-of-truth for the **Google Play Console Data Safety** form (Android)
> and the **Apple App Store Connect App Privacy** nutrition label (iOS).
> Issues: [#143](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/143)
> (Android) + [#123](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/123)
> (iOS). Parent Epic: [#120](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/120).

This document tracks **every piece of user/device data** that SASO Willen
Edition or one of its bundled SDKs touches, so that the Play Console
Data Safety declaration and the App Store App Privacy label remain
identical and accurate. Mis-declaration is a hard rejection / takedown
risk on both stores.

If you add or remove a data-collecting SDK in [pubspec.yaml](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/blob/main/pubspec.yaml),
update this table **in the same PR**.

---

## 1. Scope & assumptions

- **App category**: Warehouse inventory management. **No financial info,
  no health data, no precise location, no advertising IDs, no marketing
  personalisation, no ad targeting.**
- **In-app purchases / paid content**: none.
- **Family / kids policy**: not declared as targeted to children.
- **Crashlytics**: **not currently bundled.** A future addition would
  require declaring `App info and performance → Crash logs` and
  `Diagnostics`.
- **Analytics**: **no analytics SDK is bundled.** `firebase_analytics`,
  `mixpanel`, `amplitude`, etc. are NOT in [pubspec.yaml](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/blob/main/pubspec.yaml).
  If added later, `App activity → App interactions / Page views` must
  be declared.
- **Feature flags**: SDKs gated by feature flags (`ff_push_fcm`,
  `ff_push_sns`, `ff_auth_firebase`, `ff_auth_cognito`, `ff_auth_oidc`)
  only collect data when the flag is ON for a given deployment. The
  Data Safety form must declare the **superset** — i.e. any SDK that
  could be enabled in any production build needs to be declared.

---

## 2. Data-collecting SDK inventory

Source: [pubspec.yaml](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/blob/main/pubspec.yaml). Last reconciled 2026-05.

| # | SDK | Pub package | Flag | Collects on device | Sent to third party? |
|---|-----|-------------|------|---------------------|----------------------|
| 1 | Firebase Messaging | `firebase_messaging` | `ff_push_fcm` | FCM registration token, Android instance ID | Yes — Google |
| 2 | Firebase Auth | `firebase_auth` | `ff_auth_firebase` | Email, password hash, Firebase UID | Yes — Google |
| 3 | Firebase Remote Config | `firebase_remote_config` | always | App instance ID (anonymous), config keys | Yes — Google |
| 4 | Firebase Core | `firebase_core` | always | Bootstraps the above; no direct collection | Yes — Google (via 1-3) |
| 5 | Amplify Flutter / Pinpoint | `amplify_flutter`, `amplify_push_notifications_pinpoint` | `ff_push_sns` | Pinpoint endpoint ID, device attrs (OS, locale, app version, timezone) | Yes — AWS |
| 6 | Amplify Auth Cognito | `amplify_auth_cognito` | `ff_auth_cognito` | Email, password, Cognito sub (UUID), refresh / access / ID tokens | Yes — AWS |
| 7 | Flutter AppAuth (OIDC) | `flutter_appauth` | `ff_auth_oidc` | Access token, ID token (claims include `sub`, `email`, `name`) | Yes — Configured IdP |
| 8 | Auth0 Flutter | `auth0_flutter` | `ff_auth_oidc` (Auth0 provider) | `user_id`, email, name, picture, profile claims | Yes — Okta / Auth0 |
| 9 | WebView (SAML SSO) | `webview_flutter` | SAML login | SAML response (attributes from IdP, signed) — passed through to SASO backend | Yes — Configured IdP + SASO backend |
| 10 | Mobile Scanner | `mobile_scanner` | always | Camera frames (barcode decode) | **No — on-device only** |
| 11 | Image Picker | `image_picker` | always | Camera frame / photo library item | **No — on-device only** (sent to SASO backend if user attaches to a record) |
| 12 | Cached Network Image | `cached_network_image` | always | URL + bytes of remote images | No third party — fetched from SASO backend |
| 13 | Connectivity Plus | `connectivity_plus` | always | Network type (wifi/cellular) — read only, not stored | No |
| 14 | URL Launcher | `url_launcher` | always | No collection (delegates to OS browser) | No |
| 15 | Secure Storage | `flutter_secure_storage` | always | App-issued JWT + refresh token (local Keychain / Keystore) | No |
| 16 | sqflite / shared_preferences / path_provider | various | always | Item catalogue cache, locale, mode preference — **no PII** | No |

In-house collection:

| Component | Data | Storage | Sent to third party? |
|---|---|---|---|
| `lib/core/storage/secure_storage.dart` | SASO session JWT, refresh token | Keychain (iOS) / Keystore (Android) | No |
| `lib/core/storage/database_helper.dart` | Item catalogue cache (product code, name, category) | App-private sqflite DB | No |
| Image attachments | User-captured photos (when explicitly attached) | Uploaded to SASO backend over HTTPS + cert pinning | SASO backend only |
| Barcode scans | Decoded payload (text) | In-memory; persisted to SASO backend only if user submits | SASO backend only |

---

## 3. Data Safety / App Privacy mapping

Each Play Data Safety category below maps 1:1 to a column in
`https://play.google.com/console/u/0/developers/.../app-content/data-safety`.
The right-hand column shows the **equivalent Apple App Privacy
category** so both forms stay in sync.

Legend:
- **Collected**: Leaves the device (transmitted off-device, even if
  ephemeral). Per Google's definition.
- **Shared**: Transferred to a third party that may process it
  independently of the app developer (so an SDK vendor counts).
- **Required**: User cannot opt out without losing core function.
- **Optional**: User can decline (e.g. push permission denied).
- **Encrypted in transit**: All traffic to the SASO backend uses TLS
  1.2+ with certificate pinning; all SDK vendors above use HTTPS.
- **User can request deletion**: Yes — via in-app account-delete flow
  (TBD #A5 ticket) and the SASO backend admin removing the row.

### 3.1 Personal info

| Field | Source SDK / code | Purpose (Play) | Optional? | Encrypted in transit | Shared with | Apple category |
|---|---|---|---|---|---|---|
| Email address | `firebase_auth`, `amplify_auth_cognito`, `auth0_flutter`, `flutter_appauth` (claim) | Account management | Required (login) | Yes (TLS + pinning) | Google / AWS / Auth0 / IdP | Contact Info → Email Address |
| Name | `auth0_flutter`, `flutter_appauth` (claim) | Account management, App functionality (display name in header) | Required if IdP returns it | Yes | Auth0 / IdP | Contact Info → Name |
| User ID (app-issued) | SASO backend `userId`, `firebase_auth` UID, Cognito `sub`, Auth0 `user_id` | Account management, App functionality, Fraud prevention | Required | Yes | Google / AWS / Auth0 (their own IDs); SASO backend (app-issued) | Identifiers → User ID |
| Password | `firebase_auth`, `amplify_auth_cognito` | Account management | Required (for password auth modes) | Yes (TLS); never logged | Google / AWS | (Apple: not declared — passwords aren't a separate App Privacy field; treated as Authentication credentials inside Contact Info) |

Notes:
- SAML / OIDC IdP-mode logins NEVER send the password to the SASO
  backend — the WebView handles the credential exchange directly with
  the IdP.

### 3.2 Financial info

**Not collected.** SASO is a warehouse inventory tool. No payments,
no purchase history, no credit info, no payroll data.

### 3.3 Photos and videos

| Field | Source | Purpose | Optional? | Encrypted in transit | Shared with | Apple category |
|---|---|---|---|---|---|---|
| Camera frames (barcode scanning) | `mobile_scanner` | App functionality (decode barcodes on-device) | Required (camera permission). User can deny permission and use manual entry. | N/A — **not transmitted** | None | (Not declared — Apple permits omission when data never leaves device) |
| Photos attached to inventory records | `image_picker` | App functionality (attach product photo) | Optional | Yes (TLS + pinning) | SASO backend only | Photos and Videos → Photos |

The Play Data Safety form treats on-device-only camera use as
**not collected**. We declare camera *permission* in the Play store
listing (`uses-permission android.permission.CAMERA`) but the Data
Safety form line is **Photos and videos → Photos / videos = Collected
(only when user attaches one)**.

### 3.4 App activity

**Not collected.** No analytics, no in-app search history exfiltration,
no page view tracking. Local search queries stay on-device against the
sqflite cache.

If `firebase_analytics` is ever added, declare:
- App activity → App interactions
- App activity → In-app search history
- App activity → Page views and taps

### 3.5 App info and performance

**Not collected today.** Crashlytics is not bundled.

If `firebase_crashlytics` or Sentry is added later, declare:
- App info and performance → Crash logs
- App info and performance → Diagnostics
- (Apple) Diagnostics → Crash Data / Performance Data

### 3.6 Device or other IDs

| Field | Source SDK | Purpose | Optional? | Encrypted in transit | Shared with | Apple category |
|---|---|---|---|---|---|---|
| FCM registration token | `firebase_messaging` | Push notifications | Optional (per-OS push prompt) | Yes | Google + SASO backend | Identifiers → Device ID |
| Android instance ID / Firebase Installation ID | `firebase_core` family | App functionality (token routing), Anti-abuse | Required when Firebase enabled | Yes | Google | Identifiers → Device ID |
| Pinpoint endpoint ID | `amplify_push_notifications_pinpoint` | Push notifications, Analytics-of-delivery | Optional (push prompt) | Yes | AWS | Identifiers → Device ID |
| Cognito identity ID (`sub` / Identity Pool ID) | `amplify_auth_cognito` | Authentication | Required if Cognito auth chosen | Yes | AWS | Identifiers → User ID |
| Firebase Auth UID | `firebase_auth` | Authentication | Required if Firebase auth chosen | Yes | Google | Identifiers → User ID |
| Auth0 `user_id` | `auth0_flutter` | Authentication | Required if Auth0 chosen | Yes | Auth0 / Okta | Identifiers → User ID |

We do **not** read `Settings.Secure.ANDROID_ID` directly, but Firebase
Analytics-flavoured SDKs (transitively pulled by `firebase_core`) may
read it. To stay conservative we declare **Device or other IDs ⇒
Collected ⇒ Shared with Google** whenever Firebase is enabled.

### 3.7 Messages

**Not collected.** No SMS, email, or in-app messaging is read or
transmitted. Push notifications received from FCM / SNS are decoded
locally and shown via the OS notification channel.

### 3.8 Audio files

**Not collected.** Microphone permission is not requested. (Verify
during the iOS Info.plist / Android manifest audit in #126.)

### 3.9 Files and docs

**Not collected.** The app does not read user documents or arbitrary
storage; image picker invokes the OS picker which returns only the
chosen item.

### 3.10 Calendar / Contacts

**Not collected.**

### 3.11 Location

**Not collected.** No `geolocator` / `location` / `flutter_native_place_picker`
SDKs in [pubspec.yaml](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/blob/main/pubspec.yaml). The IP-derived coarse
location that Pinpoint / FCM compute server-side is part of their own
data-handling and is not collected by the app per Google's definition.

### 3.12 Web browsing history

**Not collected.** WebView is only used as a transient SSO flow; we do
not retain visited URLs.

---

## 4. Per-vendor summary (Play "Data shared with third parties")

| Vendor | When | What | Vendor's disclosure page |
|---|---|---|---|
| Google (Firebase) | `ff_auth_firebase` ON, `ff_push_fcm` ON, Remote Config always | Email, UID, FCM token, Installation ID, device attrs | https://firebase.google.com/support/privacy |
| AWS (Cognito + Pinpoint) | `ff_auth_cognito` / `ff_push_sns` ON | Email, Cognito sub, Pinpoint endpoint ID, device attrs | https://aws.amazon.com/compliance/data-privacy/ |
| Auth0 / Okta | `ff_auth_oidc` ON, Auth0 provider | Email, name, profile claims, refresh token | https://auth0.com/docs/secure/data-privacy-and-compliance |
| Configured OIDC IdP | `ff_auth_oidc` ON, OIDC provider | OAuth2 tokens + ID-token claims | Per-tenant — varies |
| Configured SAML IdP | SAML login | SAML response attributes | Per-tenant — varies |

The Play Data Safety form requires us to tick **"Data is shared with
third parties"** as soon as **any** of the above is enabled in the
production build.

---

## 5. Security & user-control checklist

For each declared category in §3, the Play form asks three follow-up
questions. The answers below are the canonical values to enter.

| Question | Answer |
|---|---|
| Is data encrypted in transit? | **Yes** — TLS 1.2+ to SASO backend + cert pinning (see [`lib/core/network/`](../../lib/core/network/)); all bundled SDKs use HTTPS. |
| Can users request that data be deleted? | **Yes** — in-app account deletion (tracked under #A5) plus admin removal via the SASO web `/mypage`. Tokens cleared from secure storage on logout. |
| Do you follow the Play Families Policy? | **N/A** — not targeted at children. |
| Have you committed to the Play Developer Distribution Agreement? | **Yes** — declared on submission. |

---

## 6. Submission checklist

When the next Play Console release is created, an engineer must:

1. Open Play Console → SASO Willen Edition → **App content → Data safety**.
2. For each row in §3 above, set **Collected = Yes** with the
   `Purpose`, `Optional / Required`, and `Shared with third parties`
   values shown.
3. For categories in §3.2 / §3.4 / §3.5 / §3.7-3.12, leave
   **Collected = No**.
4. Under **Security practices**, tick the two "Yes" answers in §5.
5. Save & request review. Diff against the previous submission to
   confirm intent.
6. After approval, paste the resulting Play "data-safety summary URL"
   into the release ticket and link this document.

The equivalent steps for the Apple App Privacy label live in
[#123](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/123)
and consume the same table.

---

## 7. Change log

| Date | PR | Change |
|---|---|---|
| 2026-05-24 | #143 | Initial draft, mapping all SDKs from `pubspec.yaml` rev `0.1.0+1`. |
