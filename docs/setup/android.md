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

### 署名キーを生成（初回のみ）

```bash
keytool -genkey -v \
  -keystore android/app/saso-release.jks \
  -alias saso \
  -keyalg RSA -keysize 2048 -validity 10000
```

!!! warning "注意"
    `.jks` ファイルは **絶対に Git にコミットしないでください。**  
    `.gitignore` に `android/app/*.jks` を追加してください。

### key.properties を作成

```properties
# android/key.properties（Git 管理外）
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=saso
storeFile=saso-release.jks
```

### APK / AAB をビルド

```bash
# APK（テスト配布用）
flutter build apk --release

# AAB（Google Play 用）
flutter build appbundle --release
```

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
