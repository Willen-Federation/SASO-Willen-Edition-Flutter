# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

## [0.1.0] — 2026-04-26

### Added

- Flutter project initialized with Clean Architecture / DDD structure
- 3-tier API adapter: `mock` / `legacy` / `rest` switchable via settings
- Mock data client with 10 seed items, 3 categories, 3 shelves
- OpenFeature-compliant feature flag system with 8 flags
  - `DebugFlagProvider`: all flags ON in debug builds
  - `RemoteFlagProvider`: Firebase Remote Config with real-time updates
  - `LocalFlagProvider`: SharedPreferences-based device override
- Domain entities: `Item`, `Category`, `Feature`, `Shelf`
- Value objects with validation: `ItemId` (YYMMNNNN), `FeatureCode` (12-digit), `ShelfId` (alphanumeric + hyphen, max 15 chars)
- Offline-first `ItemRepositoryImpl` with in-memory cache
- Authentication layer: `LegacyAuthService`, `OidcAuthService`, `FirebaseAuthService`
- Push notification layer: `FcmPushService` (FCM), `SnsPushService` (Amazon SNS Pinpoint)
- Pages: Home, Item Search, Item Detail, Barcode Scanner, Category Browser, Shelf View, Server Settings, Splash
- `go_router` navigation with path parameters
- SQLite schema for `items`, `categories`, `shelves`, `cache_meta`
- Secure storage via `flutter_secure_storage` (iOS Keychain / Android Keystore)
- Barcode scanner via `mobile_scanner` (AVFoundation on iOS 26)
- Japanese localization (`app_ja.arb`) with English fallback (`app_en.arb`)
- Unit tests: value objects, feature flags, ProblemDetails, ItemRepositoryImpl
- Widget tests: ItemDetailPage, HomePage
- Integration tests: app launch, item lookup flow, barcode scanner navigation
- Makefile with targets: `setup`, `gen`, `fmt`, `analyze`, `test`, `test-unit`, `test-widget`, `test-integration`, `test-all`, `build-ios-sim`, `run-ios`, `clean`
- GitHub Actions CI: format check, static analysis, unit/widget tests, iOS simulator build
- RFC 7807 `ProblemDetails` with SASO-DOMAIN-NNNN error code extension
- Open source documentation: CONTRIBUTING, CODE_OF_CONDUCT, SECURITY

[Unreleased]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/releases/tag/v0.1.0
