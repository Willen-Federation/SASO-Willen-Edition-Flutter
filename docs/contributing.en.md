# Contributing

Contributions to SASO Willen Edition Flutter are welcome!

> The full guide lives at [CONTRIBUTING.md](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/CONTRIBUTING.md) in the repository root.

---

## Development setup

```bash
# 1. Fork & clone
git clone https://github.com/<your-name>/saso-willen-edition-flutter.git
cd saso-willen-edition-flutter

# 2. Fetch dependencies
make setup   # flutter pub get

# 3. Code generation (freezed, riverpod_annotation, go_router)
make gen     # dart run build_runner build --delete-conflicting-outputs

# 4. Run tests
make test    # unit + widget tests
```

---

## Branch naming

| Prefix | Use |
|---|---|
| `feature/` | New feature |
| `fix/` | Bug fix |
| `chore/` | Build / docs / refactor |

Example: `feature/sns-pinpoint-production`

---

## Commit messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: FCM production implementation (with token refresh)
fix: SnsPushService missing Amplify.configure() call
docs: add quick-start to README
chore: bump flutter 3.29.3
```

---

## PR merge criteria

A PR must satisfy all of the following before merge:

- [ ] `make fmt` — formatted
- [ ] `make analyze` — no static analysis warnings
- [ ] `make test` — unit + widget tests pass
- [ ] domain / data layer coverage ≥ 80%
- [ ] Security policy compliant (auth secrets stored only via `flutter_secure_storage`)

---

## License

This project is licensed under **GPL-3.0**.
By submitting a contribution you agree your code is licensed under GPL-3.0.
