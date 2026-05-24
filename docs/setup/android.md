# Android デプロイ

Android 実機・エミュレーターへのデプロイガイドです。

---

## 要件

- Android Studio または Android SDK（コマンドラインツール）
- Android 6.0（API 23）以上の端末またはエミュレーター
- JDK 17 以上

---

## エミュレーターで実行

```bash
# 利用可能な Android デバイス一覧
flutter devices

# 起動
flutter run -d <エミュレーターID>
```

---

## 実機デプロイ手順

### 1. google-services.json を配置

```bash
# Firebase Console でダウンロードしたファイルを配置
cp ~/Downloads/google-services.json android/app/
```

### 2. デバッグビルドで実行

USB デバッグを有効にした端末を接続して：

```bash
flutter run -d <デバイスシリアル>
```

### 3. FCM 通知チャネルの確認（Android 8.0+）

アプリは起動時に `saso_default_channel` という通知チャネルを自動作成します。  
**「設定」→「アプリ」→「SASO Willen Edition」→「通知」** で確認できます。

### 4. Android 13+ の通知権限

Android 13（API 33）以上では、アプリが初回起動時に通知許可ダイアログを表示します。  
**「許可」** を選択してください。

---

## リリースビルド

Google Play への配布や社内テスト配布など、本番署名鍵で `.aab` / `.apk` を
生成する手順は専用ガイドにまとめています。

[Android リリース署名手順 (docs/release/android-signing.md)](../release/android-signing.md)
を参照してください。以下のトピックを網羅しています:

- `keytool` でのキーストア生成 (`-validity 10000` 要件含む)
- `assetlinks.json` 用 SHA-256 fingerprint の取得
- キーストアの 1Password / KMS での安全な保管ポリシー
- Play App Signing への移行検討
- `flutter build appbundle --release` 実行とトラブルシューティング

クイックリファレンスとしては:

```bash
# 1. android/key.properties.template をコピーして実値を埋める
cp android/key.properties.template android/key.properties

# 2. リリースビルド (Play Console 用 .aab)
flutter build appbundle --release
```

`key.properties` が無い状態で `flutter build appbundle --release` を実行
すると Gradle がエラーで停止します (debug keystore へのフォールバックは
意図せぬ本番出荷を防ぐため `Release` タスクでは無効です)。

!!! info "16 KB page size 検証 (Play Store 提出前必須)"
    2025-11-01 以降に targetSdk 35 で Play Store 提出する AAB は、
    すべての 64bit native `.so` が 16 KB ページサイズに対応している必要があります。
    手順は [Android 16 KB page size 検証](../troubleshooting/android-16kb-page-size.md) 参照。

---

## トラブルシューティング

??? failure "Gradle ビルドが失敗する"
    ```bash
    flutter clean
    cd android && ./gradlew clean
    cd ..
    flutter build apk
    ```

??? failure "`google-services.json` パッケージ名エラー"
    `google-services.json` 内の `package_name` が `android/app/build.gradle` の  
    `applicationId` と一致していることを確認してください。
