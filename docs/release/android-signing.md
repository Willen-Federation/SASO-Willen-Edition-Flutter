# Android リリース署名手順

Google Play へ配布する `.aab` を作成するための、リリースキーストア生成・
配置・保管・ビルドの完全ガイドです。リリース担当者は **必ずこの手順を
通読** してからキーストアを発行してください。

!!! danger "リリース署名鍵を紛失すると、同じ `applicationId` で Play
    Console に新しいバージョンをアップロードできなくなります。"
    バックアップと安全な保管を必ず行ってください
    (詳細は[キーストアの保管ポリシー](#keystore-storage) を参照)。

関連 Issue:

- #22 (closed) — debug keystore でリリースを署名していた問題の修正
- #156 — 本ドキュメント (key.properties.template + 手順整備)
- #A5 — Digital Asset Links の SHA-256 fingerprint

---

## 概要

このリポジトリの Android リリースビルドは
[`android/app/build.gradle.kts`](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/android/app/build.gradle.kts)
で **`android/key.properties` から署名情報を読み込む** 仕組みです。

| ファイル | 役割 | Git 管理 |
| --- | --- | --- |
| `android/key.properties.template` | プロパティ書式のサンプル | 追跡する (テンプレート) |
| `android/key.properties` | 実際のパスワード等 | **絶対に追跡しない** (`.gitignore`) |
| `keystore/saso-release.jks` | 署名鍵本体 | **絶対に追跡しない** (`*.jks` で除外) |

`key.properties` が無い状態で `flutter build appbundle --release` を実行
すると **Gradle が失敗** します (#22 のフォールバック撤去)。`flutter run
--release` などの **ローカル動作確認** は debug keystore でフォールバック
するため、開発者は引き続きキーストア未設定でもアプリを動かせます。

---

## 1. キーストアを生成する (初回のみ)

リリース担当者の **ローカルマシン** (ネットワーク非接続 / オフライン推奨)
で以下を実行します。CI 環境では生成しないでください。

```bash
mkdir -p keystore
keytool -genkey -v \
  -keystore keystore/saso-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias saso
```

対話プロンプトでは:

- **キーストアパスワード**: ランダム生成した強力なもの (例: `openssl rand -base64 32`)
- **キーパスワード**: キーストアパスワードと同じでも可 (`keytool` の慣例)
- **氏名 / 組織 / 国名**: 公開される配布鍵証明書 (CN=Willen Federation,
  O=Willen Federation, C=JP など適切な値) を入れる

!!! warning "`-validity 10000` (約 27 年)"
    Play Console は **アップロード鍵を発行から 25 年以上有効** であることを
    要求します。`-validity 10000` (約 27.4 年) でこの要件を満たします。
    短い値で生成すると Play 側で受理されません。

---

## 2. SHA-256 fingerprint を取得する

`assetlinks.json` (#A5 / Digital Asset Links) や Firebase Auth / OAuth 設定
などで配布鍵の SHA-256 が必要です。

```bash
keytool -list -v \
  -keystore keystore/saso-release.jks \
  -alias saso \
  | grep SHA-256
```

出力例:

```text
         SHA-256: AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89
```

この値は **コロン区切り 32 バイト** で、`assetlinks.json` の
`sha256_cert_fingerprints` 配列にそのまま入ります。

!!! info "Play App Signing を使う場合"
    [Play App Signing](#play-app-signing) を採用するなら、配布鍵の
    SHA-256 は **Play Console の "アプリの整合性" 画面** で取得します
    (上記 `keytool` で取れるのは "アップロード鍵" の SHA-256 のみ)。

---

## 3. `android/key.properties` を作成する

リポジトリに **追跡されていないファイル** として作成します。テンプレートを
コピーするのが楽です。

```bash
cp android/key.properties.template android/key.properties
$EDITOR android/key.properties  # __FILL_IN__ を実値に書き換える
```

`storeFile` は `android/app/build.gradle.kts` から見た相対パス、または
絶対パスです。`keystore/` をリポジトリルートに置く本ガイドの構成では
`../keystore/saso-release.jks` (= `android/app/../keystore/...`) になります。

!!! danger "key.properties を Git にコミットしない"
    `.gitignore` で `**/android/key.properties` を除外していますが、
    `git add -f` で強制追加しないよう注意してください。万が一プッシュ
    してしまった場合は **キーストアパスワードを直ちにローテーション**
    し、過去コミットから履歴を削除してください
    (`git filter-repo` 推奨)。

---

<a id="keystore-storage"></a>
## 4. キーストアの安全な保管

紛失すると同じ `applicationId` で Play に新バージョンを上げられなくなり、
**取り返しがつきません**。以下のいずれか (または複数) で必ず冗長化します。

### 推奨

- **1Password の Secure Note + 添付ファイル**: `saso-release.jks` 本体と
  `storePassword` / `keyPassword` を同一エントリーに添付。Willen Federation
  の共有 Vault に保存し、リリース担当者のみアクセス可能にする。
- **AWS Secrets Manager / GCP Secret Manager / HashiCorp Vault** に
  base64 エンコードで格納。CI から自動でリリースを切る場合は KMS 経由で
  鍵をマウントする (生 `.jks` をリポジトリに置かない)。

### 最低限

- リリース担当者のローカルマシン (FileVault 暗号化済み macOS / LUKS 暗号化
  済み Linux など) + **オフラインバックアップ** (USB を金庫に保管)

### やってはいけないこと

- `.jks` を Slack / Email / Google Drive (Vault 外) で共有
- 平文のパスワードを Notion / Confluence に貼る
- 個人の Dropbox / iCloud にバックアップ

---

<a id="play-app-signing"></a>
## 5. Play App Signing への移行検討

[Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
は **配布鍵を Google が KMS で管理** する仕組みで、アプリ作者は
"アップロード鍵" のみを保持します。Play Console で新規アプリを作成する
場合は **デフォルトで有効** です。

| | 自己管理 (本ドキュメントの手順) | Play App Signing |
| --- | --- | --- |
| 配布鍵の管理者 | 自分 | Google |
| 紛失時の影響 | アプリの新バージョン上げ不可 | アップロード鍵のみ再発行可能 |
| 配布鍵 SHA-256 取得 | `keytool -list` | Play Console "アプリの整合性" |
| Universal Links / DAL の登録 | アップロード鍵 + Play 配布鍵の両方 | 配布鍵のみ (Play Console から取得) |

!!! tip "本プロジェクトの方針"
    新規 Play 申請時は **Play App Signing を採用する** ことを推奨します。
    `keystore/saso-release.jks` は **アップロード鍵** として残し、配布鍵は
    Google に管理させます。配布鍵 SHA-256 は Play Console からコピー
    して [assetlinks.json (#A5)](https://github.com/willen-federation/saso-willen-edition-flutter/issues/A5)
    に転記します。

---

## 6. リリースビルド手順

`android/key.properties` を配置した状態で:

```bash
# 1. クリーンビルド
flutter clean
flutter pub get

# 2. AAB を生成 (Play Console 用)
flutter build appbundle --release

# 出力先: build/app/outputs/bundle/release/app-release.aab
```

`.aab` を Play Console の "本番トラック" または "内部テスト" にアップロードします。

### APK で配布する場合 (社内テスト等)

```bash
flutter build apk --release

# 出力先: build/app/outputs/flutter-apk/app-release.apk
```

### key.properties が無い状態でのビルド挙動

[`android/app/build.gradle.kts`](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/android/app/build.gradle.kts)
は `Release` を含む Gradle タスクが呼ばれた時に
`keystoreProperties["storeFile"]` の有無を検査します。

- **`key.properties` あり** → リリース keystore で署名 (本番出荷可)
- **`key.properties` なし、`flutter run --release` などローカル動作確認**
  → debug keystore にフォールバック (Play へアップロード不可)
- **`key.properties` なし、`flutter build appbundle --release` などリリース
  ビルド** → Gradle が `GradleException` で停止。表示されるメッセージから
  本ドキュメントへ誘導されます。

---

## 7. トラブルシューティング

??? failure "`Failed to read key saso from store ...`"
    `keyPassword` か `storePassword` が間違っています。`keytool -list -v`
    でキーストアを開ければパスワード自体は正しいので、`key.properties`
    の値を再確認してください。

??? failure "`Keystore file '/path/to/saso-release.jks' not found for signing config 'release'`"
    `storeFile` のパスが間違っています。`android/app/build.gradle.kts`
    から見た相対パス、または絶対パスで指定してください。

??? failure "`key.properties missing — see docs/release/android-signing.md`"
    リリースビルドを試みたが `key.properties` が無い状態です。本ドキュメント
    の手順 1〜3 に従って配置してください。`flutter run --release` などの
    ローカル動作確認だけが目的であれば、`key.properties` 不要 (debug
    keystore にフォールバック) です。

??? failure "Play Console: `アップロード証明書が一致しません`"
    Play App Signing 有効環境で別の keystore で署名してしまったケースです。
    Play Console の "アプリの整合性 → アップロード鍵証明書をリセット" から
    再登録できます (Google サポートのレビューが入ります)。

---

## 参考リンク

- [Sign your app (Android Developers)](https://developer.android.com/studio/publish/app-signing)
- [Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
- [Digital Asset Links (assetlinks.json)](https://developers.google.com/digital-asset-links/v1/getting-started)
- 本リポジトリ:
  - [`android/app/build.gradle.kts`](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/android/app/build.gradle.kts) — 署名設定の実装
  - [`android/key.properties.template`](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/android/key.properties.template) — テンプレート
  - [`.gitignore`](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/.gitignore) — `key.properties` と `*.jks` の除外
