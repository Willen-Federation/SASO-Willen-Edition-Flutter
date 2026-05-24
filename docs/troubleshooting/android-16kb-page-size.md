# Android 16 KB page size 対応の検証手順

Google Play は **2025-11-01 以降に targetSdk 35 を対象に新規/更新されるアプリ**
について、64bit デバイスで **16 KB メモリページサイズ**に対応していることを
必須化しました。Pixel 8 / 9 系の新 ROM は 16 KB-aligned でない `.so`
ファイルを含むアプリを起動できません。

本アプリは多数のネイティブ依存（sqflite / mobile_scanner / firebase_* /
amplify_* / auth0_flutter / flutter_secure_storage / webview_flutter /
connectivity_plus）を抱えています。本書は **Pre-launch report に 16 KB
警告が出ない**ことをローカルで事前検証するための手順です。

参考: [Support 16 KB page sizes (developer.android.com)](https://developer.android.com/guide/practices/page-sizes)

---

## ビルド設定

本リポジトリは AGP 8.9.1 + NDK 27（Flutter 3.41 系デフォルト）を採用しており、
16 KB 対応の最低ライン（AGP 8.5.1+ / NDK 27+）を満たしています。

`android/app/build.gradle.kts` の `packagingOptions` ブロックで
`useLegacyPackaging = false` を明示し、AGP が `.so` を **未圧縮かつ
ページアラインで APK に格納**するようにしています。これがランタイムから
16 KB 境界で mmap される前提条件です。

```kotlin
packagingOptions {
    jniLibs {
        useLegacyPackaging = false
    }
}
```

---

## 前提ツール

以下のツールをローカルにインストールしてください。Android Studio をインストール済みなら
`$ANDROID_HOME/cmdline-tools/latest/bin` および `$ANDROID_HOME/build-tools/<version>/`
に大体揃っています。

| ツール | 役割 | 入手元 |
|---|---|---|
| `bundletool` | AAB から universal APK を生成 | [GitHub release](https://github.com/google/bundletool/releases) |
| `apkanalyzer` | APK / AAB の構造ダンプ（16 KB レポートを含む） | Android SDK Command-line Tools |
| `unzip` | APK 内 `.so` 取り出し | OS 標準 |
| `objdump` | LOAD segment の `align` を読む | Xcode CLT (`llvm-objdump`) または NDK (`llvm-objdump` / `aarch64-linux-android-objdump`) |
| `zipalign` | APK の zip-level アライメント確認 (`-P 16`) | Android SDK Build-Tools |

> **macOS の objdump**: 標準の BSD `objdump` は ELF を解析できません。
> Xcode CLT の `llvm-objdump` か Android NDK 同梱の `aarch64-linux-android-objdump`
> を使用してください。

---

## 手順

### 1. リリース AAB をビルド

```bash
flutter build appbundle --release
```

出力: `build/app/outputs/bundle/release/app-release.aab`

> **注**: 16 KB アライメントは AGP の出力時に決まります。
> `--debug` ビルドではこの保証はありません。必ず `--release` で確認します。

### 2. AAB から universal APK を生成

```bash
# 鍵が必要（debug.keystore でも可、Play 提出時は production keystore）
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=build/app-release.apks \
  --mode=universal \
  --ks=$HOME/.android/debug.keystore \
  --ks-key-alias=androiddebugkey \
  --ks-pass=pass:android \
  --key-pass=pass:android

unzip -o build/app-release.apks -d build/app-release-apks/
# universal.apk が build/app-release-apks/ 直下に展開される
```

### 3. すべての `.so` の LOAD segment が 16 KB-aligned か確認

ELF の Program Header 内 LOAD segment の `align` (= `p_align`) が
`0x4000` (16384, 16 KB) 以上であれば OK。`0x1000` (4 KB) のままなら NG。

```bash
mkdir -p build/check-so
unzip -j build/app-release-apks/universal.apk \
  'lib/arm64-v8a/*.so' -d build/check-so/

# llvm-objdump (Xcode CLT 同梱) を想定。NDK 同梱 objdump でも可。
for so in build/check-so/*.so; do
  echo "=== $(basename "$so") ==="
  llvm-objdump -p "$so" | grep -E '^\s*LOAD' | head -4
done
```

**期待出力**: 各 `.so` の LOAD 行が `align 2**14` (= 16384) になっていること。

```
=== libsqlite3.so ===
    LOAD off    0x0000000000000000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**14
    LOAD off    0x0000000000004000 vaddr 0x0000000000004000 paddr 0x0000000000004000 align 2**14
```

`align 2**12` (= 4096) のものがあれば **そのライブラリのベンダ SDK が
16 KB 未対応**です。

### 4. zipalign で APK レベルの 16 KB-page 整合を確認

```bash
zipalign -c -P 16 -v 4 build/app-release-apks/universal.apk
```

末尾に `Verification successful` が出れば OK。
`Verification FAILED` の場合は zip エントリのオフセットが 16 KB の倍数で
ない `.so` が含まれています。

### 5. apkanalyzer の 16 KB レポート（補足）

build-tools 35 以降の `apkanalyzer` には 16 KB チェック機能があります。

```bash
apkanalyzer files cat \
  --file lib/arm64-v8a/libflutter.so \
  build/app-release-apks/universal.apk \
  > /dev/null   # exit code が 0 で読めれば構造的に OK
```

詳細レポートが必要なら Play Console の **Pre-launch report** が最も信頼できます
(下記 §7)。

---

## 6. 16 KB 未対応の依存を見つけた場合の対処

調査ログ (`align 2**12` が出たライブラリ名) を **Issue #147** にコメント
してください。対処方針は次のいずれかです。

| 状況 | 対応 |
|---|---|
| 依存パッケージの新版で対応済み | `pubspec.yaml` でバージョン上げ → `flutter pub upgrade` |
| 上流が未対応だが代替プラグインがある | 差し替えを検討（feature flag で並行運用が可能なら推奨） |
| 上流が未対応で代替もない | Issue #147 を blocker のまま残し、Play Console 提出を保留 |

### 既知の警戒ポイント (本リポジトリの依存)

| パッケージ | 観点 |
|---|---|
| `sqflite` 2.4.x | SQLite 同梱バージョン。3.46+ なら 16 KB OK |
| `mobile_scanner` 7.x | iOS は AVFoundation のため Android は MLKit 不使用。MLKit を引き込んでいない構成のはず |
| `firebase_*` 6.x / 16.x | gRPC native (`libgrpc.so`)。Firebase BoM 33+ で 16 KB 対応 |
| `amplify_*` 2.x | AWS SDK ネイティブ。最新 (2.11+) は 16 KB 対応 |
| `auth0_flutter` 1.14 | Auth0.Android SDK。3.0+ で 16 KB 対応 |
| `flutter_secure_storage` 10.x | JNI のみで `.so` を持たない（OK） |

> 依存ベンダの 16 KB 対応状況はリリース頻度が高いため、Play Console 提出
> 直前に再検証してください。

---

## 7. Play Console Pre-launch report での最終確認

1. Play Console → **テスト → 内部テスト** にリリース作成
2. `app-release.aab` をアップロード
3. リリースを公開（テスター 0 人でも Pre-launch は走る）
4. **「リリース → Pre-launch report」** を開く
5. **「警告」** タブに *16 KB page size* に関する項目が出ていないことを確認

**警告が出る場合**: 該当する `.so` がレポートに列挙されるので、上記 §6 の
表に従って依存を更新してください。

---

## 8. CI への組み込み（任意）

将来 `make build-aab` (Epic #139 / Issue #154) と統合する際は、AAB ビルド
後に zipalign 検証を CI に追加することを推奨します。

```bash
# Makefile 例（#154 で導入する場合）
build-aab:
	$(FLUTTER) build appbundle --release
	zipalign -c -P 16 -v 4 \
	  build/app/outputs/bundle/release/app-release.aab \
	  || (echo "16 KB page alignment check FAILED"; exit 1)
```

---

## 関連 Issue / PR

- Epic: [#139](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/139) Google Play 準拠 & Play Store v1.0
- 親依存: #140 (A1) targetSdk 35 明示固定
- 本書: #147 (B8) 16 KB page size 対応検証
- 関連: #154 (E15) Makefile build-aab タスク
