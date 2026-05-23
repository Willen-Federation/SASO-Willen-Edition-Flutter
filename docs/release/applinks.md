# Android App Links / iOS Universal Links 公開ノート

Issue: [#144 — assetlinks.json 公開 + custom-scheme intent-filter 廃止](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/144)

Parent epic: [#139 (Google Play 準拠 & Play Store v1.0 リリース準備)](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/139)
Related: [#25 (OAuth/SAML callback URL scheme hijack — closed)](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/25)

> **背景**: アプリ側 (`android/app/src/main/AndroidManifest.xml` /
> `ios/Runner/Runner.entitlements`) はすでに App Links / Universal Links を
> プライマリ・チャネルとして宣言済みです。検証は IdP ホスト
> `auth.willen.jp` 側で公開する 2 種類の JSON ファイルに依存し、これらが
> 公開されるまでは Android で custom-scheme フィルター (`jp.willen.saso://`)、
> iOS で `CFBundleURLSchemes` の同名スキームが互換フォールバックとして
> 残ります。本ドキュメントは **infra / release-eng チーム** に向けた公開
> 手順と、公開後にモバイル側で実施するクリーンアップをまとめたものです。

---

## 完了定義 (Definition of Done)

| # | 担当 | 内容 | 状況 |
|---|---|---|---|
| 1 | release-eng | リリース keystore (#157, 旧 #E17) の SHA-256 fingerprint を取得 | ⛔ blocked on keystore 生成 |
| 2 | infra | `https://auth.willen.jp/.well-known/assetlinks.json` を公開 | ⛔ pending |
| 3 | infra | `https://auth.willen.jp/.well-known/apple-app-site-association` を公開 | ⛔ pending |
| 4 | mobile | `adb shell pm get-app-links jp.willen.saso.saso_willen_edition` で `verified=true` を確認 | ⏳ infra 公開後 |
| 5 | mobile | iOS 実機で Universal Link 動作確認 (`xcrun simctl openurl` 等) | ⏳ infra 公開後 |
| 6 | mobile | `AndroidManifest.xml` から compat custom-scheme intent-filter を削除 | ⏳ infra 公開後 |
| 7 | mobile | `ios/Runner/Info.plist` から `CFBundleURLSchemes` の `jp.willen.saso` を削除 (要影響範囲再確認) | ⏳ infra 公開後 |
| 8 | mobile | `Runner.entitlements` の `TODO(infra)` コメントを削除 | ⏳ infra 公開後 |
| 9 | mobile | `AndroidManifest.xml` の `TODO(infra)` コメントを削除 | ⏳ infra 公開後 |

---

## 1. リリース keystore の SHA-256 fingerprint 取得

assetlinks.json には **リリース署名鍵の SHA-256 fingerprint** が必要です。
デバッグキーストアの fingerprint は本番 APK / AAB の署名検証には使えません
（Play App Signing を使う場合は別途 Play Console の Upload key /
App signing key の双方を登録します）。

### ローカル keystore の場合

```bash
keytool -list -v \
  -keystore android/app/saso-release.jks \
  -alias saso \
  -storepass "$STORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  | grep -i "SHA-256:"
```

出力例:

```text
SHA-256: AB:CD:EF:...:99
```

### Play App Signing を使う場合

Google Play Console → **Setup → App signing** ページの
**App signing key certificate** セクションに表示される SHA-256
fingerprint が、Play でユーザーに配布される APK/AAB の署名に使われるため、
assetlinks には **App signing key (= deployment key) の SHA-256** を登録
します。Upload key の fingerprint も登録しておくと Internal Testing /
sideload テスト時に同じ JSON で検証できます。

---

## 2. `assetlinks.json` の内容と公開先

**公開先 URL** (HTTPS 必須・リダイレクト不可・`Content-Type: application/json`):

```text
https://auth.willen.jp/.well-known/assetlinks.json
```

**ファイル本文** (複数 fingerprint 対応版):

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "jp.willen.saso.saso_willen_edition",
      "sha256_cert_fingerprints": [
        "AB:CD:EF:...:99",
        "12:34:56:...:78"
      ]
    }
  }
]
```

- `package_name` は `android/app/build.gradle.kts` の `applicationId` と
  完全一致させる (`jp.willen.saso.saso_willen_edition`)。
- `sha256_cert_fingerprints` は配列。Play App Signing 利用時は
  **App signing key** と **Upload key** の両方を登録。
- 公開後は CDN / リバースプロキシのキャッシュを **必ず purge** し、
  以下で 200 + 正しい本文が返ることを確認:
  ```bash
  curl -fsSL -H 'Accept: application/json' \
    https://auth.willen.jp/.well-known/assetlinks.json
  ```

### 公開要件 (Google 仕様より)

- HTTPS (有効な TLS 証明書) — HTTP は不可
- 3xx リダイレクト不可 (200 直接応答)
- `Content-Type: application/json` (`text/html` 等では拒否)
- 200 OK でファイル全体が返る (gzip OK)
- 同一 host (`auth.willen.jp`) でホスト

参考: <https://developers.google.com/digital-asset-links/v1/getting-started>

---

## 3. `apple-app-site-association` (AASA) の内容と公開先

iOS 側との整合性確認のため、同時に AASA も公開してください。

**公開先 URL** (HTTPS 必須・`Content-Type: application/json` 推奨):

```text
https://auth.willen.jp/.well-known/apple-app-site-association
```

**ファイル本文** (`TEAM_ID` は Apple Developer Portal の Team ID、
`jp.willen.saso.saso_willen_edition` は iOS の bundle identifier。
Android と Apple で同じ値を使用):

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appIDs": ["TEAM_ID.jp.willen.saso.saso_willen_edition"],
        "components": [
          {
            "/": "/callback*",
            "comment": "OAuth/SAML/OIDC callback"
          }
        ]
      }
    ]
  }
}
```

- ファイル名に拡張子 (`.json`) を **付けない**。
- 認証/コールバック以外のパスを Universal Link 経路にしない場合は
  `components.* /` を `/callback*` に限定 (本アプリは `/callback` のみ)。
- entitlements 側 `applinks:auth.willen.jp` と一致していることを再確認
  (`ios/Runner/Runner.entitlements`)。

参考: <https://developer.apple.com/documentation/xcode/supporting-associated-domains>

---

## 4. 検証 (mobile)

### Android — App Links が verified=true になっているか

リリース署名済み APK / AAB をインストール後:

```bash
adb shell pm get-app-links jp.willen.saso.saso_willen_edition
```

期待出力:

```text
Package: jp.willen.saso.saso_willen_edition
  ID: ...
  Signatures: [...]
  Domain verification state:
    auth.willen.jp: verified
```

- `verified` ではなく `none` や `error` の場合、Play Console の **App
  signing key の SHA-256** と assetlinks 内の値、`applicationId` の一致を
  再確認してください。
- domain verification は **インストール時 / アップデート時** にしか走らない
  ため、再検証したい場合はアンインストール → 再インストール。

### Android — 実際の deep link でテスト

```bash
adb shell am start -a android.intent.action.VIEW \
  -d 'https://auth.willen.jp/callback?code=test' \
  jp.willen.saso.saso_willen_edition
```

`CallbackActivity` がブラウザ選択ダイアログを介さず直接起動すれば成功。

### iOS — Universal Link がアプリで開くか

```bash
xcrun simctl openurl booted 'https://auth.willen.jp/callback?code=test'
```

または実機 Safari でリンクをタップ → アプリが起動する。

`swcd` (Apple の Shared Web Credentials Daemon) ログで AASA fetch の成否を
確認:

```bash
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.apple.swc"'
```

---

## 5. 公開完了後のモバイル側クリーンアップ

両 JSON が公開され `verified=true` を確認できた段階で、別 PR で以下を
実施し、custom-scheme による intent ハイジャック面を完全に閉じます。

### `android/app/src/main/AndroidManifest.xml`

- `flutter_web_auth_2 (compat)` 名義の `<intent-filter>` ブロック
  (`<data android:scheme="jp.willen.saso"/>` を含む) を削除。
- `TODO(infra): publish assetlinks.json ...` コメントを削除。
- `manifestPlaceholders["auth0Scheme"] = "jp.willen.saso"` および
  `manifestPlaceholders["appAuthRedirectScheme"] = "jp.willen.saso"`
  (`android/app/build.gradle.kts`) は auth0_flutter / flutter_appauth の
  内部要求であり、Auth0 SDK 側を https コールバックに切り替えるまでは
  そのまま残します。SDK 側を切り替えるタイミングで併せて削除/変更。

### `ios/Runner/Info.plist`

- `CFBundleURLTypes` の `jp.willen.saso` エントリを削除 (auth0_flutter /
  flutter_appauth が iOS でも custom-scheme フォールバックを要求しなく
  なってから)。
- 削除前に SAML/OIDC/Auth0 全パスが Universal Link で動くことを
  TestFlight ビルドで実機検証する。

### `ios/Runner/Runner.entitlements`

- `TODO(infra): publish the AASA file ...` コメントを削除。
- `com.apple.developer.associated-domains` の値はそのまま (現状の
  `applinks:auth.willen.jp` 維持)。

### ドキュメント

- 本ファイル (`docs/release/applinks.md`) の **完了定義** 表を全部
  チェック済みに更新し、`docs/security/medium-audit-2026-05-17.md` の
  該当セクションに「Android App Links / iOS Universal Links 完全移行
  完了」を追記。

---

## 6. ロールバック手順

公開後に何らかの理由で App Links 検証が失敗し続け、SSO が壊れる場合:

1. infra: `assetlinks.json` / AASA は **公開のまま** にする
   (削除すると検証キャッシュが ` denied` で残るデバイスが出る)。
2. mobile: custom-scheme `<intent-filter>` を削除済みの PR を revert する
   緊急パッチを出す (release 候補ブランチからの hotfix)。
3. 原因切り分けは `adb shell pm get-app-links` と `swcd` ログを最優先で
   確認。SHA-256 不一致 / `Content-Type` 誤り / リダイレクトが主因の
   ほとんどです。

---

## 参考リンク

- [Verify Android App Links — Android Developers](https://developer.android.com/training/app-links/verify-android-applinks)
- [Digital Asset Links V1 — Google Developers](https://developers.google.com/digital-asset-links/v1/getting-started)
- [Supporting associated domains — Apple Developer](https://developer.apple.com/documentation/xcode/supporting-associated-domains)
- [Statement List Generator and Tester](https://developers.google.com/digital-asset-links/tools/generator)
