# SASO Willen Edition — Getting Started

**SASO Willen Edition** is a Flutter mobile terminal for the SASO warehouse inventory management system.
It lets warehouse workers run stock lookups, barcode scans, and shelf management from a smartphone.

---

## Requirements

| Item | Required |
|------|----------|
| Flutter | 3.29+ |
| Dart | 3.7+ |
| iOS | 15.5+ (iPhone 11 or newer recommended) |
| Android | API 23 (Android 6.0)+ |
| Xcode | 16+ (for iOS builds) |

---

## Quick start (5 min)

You can launch the app without editing a single line of code.

### 1. Clone the repository

```bash
git clone https://github.com/willen-federation/saso-willen-edition-flutter.git
cd saso-willen-edition-flutter
```

### 2. Fetch dependencies

```bash
flutter pub get
```

### 3. Run in the simulator (mock mode)

Boots without a server or Firebase config.

```bash
# List available devices
flutter devices

# Launch on an iPhone simulator
flutter run -d <device-id>
```

If the banner reads **"Mock mode (no server required)"**, you're up and running.

!!! tip "About mock data"
    Mock mode shows fictitious inventory data. To connect to a real SASO server, see the [Legacy API guide](api/legacy.md).

---

## Production setup (no code edits required)

To enable push notifications and authentication, drop the following files in place after downloading them from the Firebase / AWS console.

| Feature | File needed | Location |
|---------|-------------|----------|
| iOS FCM / Firebase Auth | `GoogleService-Info.plist` | `ios/Runner/` |
| Android FCM / Firebase Auth | `google-services.json` | `android/app/` |
| SNS Pinpoint (optional) | `lib/amplifyconfiguration.dart` | `lib/` |

For details, see each setup guide:

- [Firebase setup](setup/firebase.md)
- [AWS Amplify Pinpoint setup](setup/amplify.md)
- [iOS deployment](setup/ios.md)
- [Android deployment](setup/android.md)

---

## Architecture overview

```
Presentation  (Riverpod + go_router)
    ↓
Feature Flags (OpenFeature — Debug: all ON / Release: Firebase Remote Config)
    ↓
Auth          (Legacy Cookie / OIDC / Firebase Auth — flag-toggled)
Push          (FCM / SNS Pinpoint — flag-toggled)
    ↓
Domain        (Entity / ValueObject / Repository interface / UseCase)
    ↓
Data          (Mock / Legacy API / REST v1 adapters + SQLite cache)
```

---

## License

GPL-3.0 — see [LICENSE](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/LICENSE).
GPL-3.0 is an [OSI-approved open source license](https://opensource.org/licenses/GPL-3.0).

See the [Code of Conduct](code-of-conduct.md) and [Changelog](changelog.md) for community guidelines and release history.

---

## Hosting

This site is hosted by [Netlify](https://www.netlify.com).

[![Deploys by Netlify](https://www.netlify.com/img/global/badges/netlify-color-accent.svg)](https://www.netlify.com)
