# Contributing to SASO Willen Edition Flutter

Thank you for your interest in contributing! This document explains how to set up the development environment and submit changes.

## Prerequisites

- Flutter 3.29+ / Dart 3.7+
- Xcode 16+ with Command Line Tools
- iPhone 17 simulator (iOS 26.4, UUID: `6220269A-82B9-4382-B652-952116BA7E80`)
- Git

## Development Setup

```bash
git clone https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter.git
cd SASO-Willen-Edition-Flutter

make setup  # flutter pub get
make gen    # run code generation
```

## Firebase Configuration

Firebase configuration files are excluded from version control. To work with Firebase features:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Download `GoogleService-Info.plist` and place it at `ios/Runner/GoogleService-Info.plist`
3. Download `google-services.json` and place it at `android/app/google-services.json`

**Never commit these files.** They are in `.gitignore`.

Without Firebase configuration, the app starts in mock mode and Firebase features are skipped gracefully.

## Workflow

### Branches

| Prefix | Purpose |
|---|---|
| `feature/` | New features |
| `fix/` | Bug fixes |
| `chore/` | Maintenance, dependency updates, CI |
| `docs/` | Documentation only |

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add barcode scan for shelf routing
fix: correct ItemId month validation boundary
chore: bump mobile_scanner to 6.0.11
docs: update Firebase setup instructions
```

### Pull Request Checklist

Before opening a PR, ensure all of the following pass:

```bash
make fmt      # dart format
make analyze  # flutter analyze (zero errors)
make test     # unit + widget tests pass
```

For changes to domain or data layers, also verify:

```bash
make test-integration  # iPhone 17 integration tests
```

Coverage requirements:
- `domain/` and `data/` layers: **≥ 80%** line coverage

### Code Style

- Follow the rules in `analysis_options.yaml`
- No comments explaining *what* the code does — only *why* if non-obvious
- Prefer `const` constructors where possible
- Use `freezed` for all data models

## Architecture Rules

- **Domain layer** must not import from `data/` or `presentation/`
- **Data layer** must not import from `presentation/`
- Feature flags control runtime behavior; never use `if (kDebugMode)` for business logic
- Authentication and push services are always bundled; flags select which is active at runtime

## License

By contributing, you agree your contributions are licensed under GPL-3.0.
