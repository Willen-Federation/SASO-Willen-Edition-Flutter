# iOS デプロイ

iPhone / iPad 実機へのデプロイガイドです。  
**コードの編集は不要です。** Xcode での署名設定のみ必要です。

---

## 要件

- macOS + Xcode 16 以上
- Apple Developer Program（実機テスト・配布時）
- iOS 15.5 以上の端末

---

## シミュレーターで実行

```bash
# 利用可能なシミュレーター一覧
xcrun simctl list devices available

# 例: iPhone 16 Pro で起動
flutter run -d "iPhone 16 Pro"
```

---

## 実機デプロイ手順

### 1. Xcode で署名を設定

1. `ios/Runner.xcworkspace` を Xcode で開く
2. **Runner** ターゲット → **「Signing & Capabilities」** タブ
3. **「Automatically manage signing」** にチェック
4. **Team** を選択（Apple Developer アカウント）

### 2. バンドル ID を確認

`ios/Runner.xcodeproj/project.pbxproj` の `PRODUCT_BUNDLE_IDENTIFIER` が  
Firebase に登録したバンドル ID と一致していることを確認してください。

```
jp.willen.saso（デフォルト）
```

### 3. GoogleService-Info.plist を配置

```bash
# Firebase Console でダウンロードしたファイルを配置
cp ~/Downloads/GoogleService-Info.plist ios/Runner/
```

Xcode のプロジェクトナビゲーターで **Runner グループ** に表示されていることを確認してください。  
表示されない場合は右クリック →「Add Files to "Runner"」で追加します。

### 4. APNs の設定

本番プッシュ通知には APNs キーが必要です（[Firebase セットアップ](firebase.md#4-fcm) 参照）。

プッシュ通知ケイパビリティを Xcode で確認：

1. Runner ターゲット → **「Signing & Capabilities」**
2. **「Push Notifications」** が追加されていることを確認
3. **「Background Modes」→「Remote notifications」** が有効になっていることを確認

### 5. ビルド・実行

```bash
# デバッグビルド（開発用）
flutter run -d <デバイスUUID>

# リリースビルド
flutter run --release -d <デバイスUUID>
```

---

## App Store 配布

```bash
# IPA をビルド
flutter build ipa --release

# Xcode Organizer または Transporter でアップロード
open build/ios/archive/Runner.xcarchive
```

---

## トラブルシューティング

??? failure "Provisioning profile が見つからない"
    Xcode で自動署名を使用している場合、インターネット接続が必要です。  
    `flutter clean && flutter pub get` を試してください。

??? failure "pod install が失敗する"
    ```bash
    cd ios
    pod repo update
    pod install
    ```

??? failure "iOS 26 シミュレーターで flutter test が失敗する"
    Flutter 3.29.x は iOS 26 SDK をサポートしていません（2025年6月以降のリリースで対応予定）。  
    iOS 18.x シミュレーターを使用してください：
    ```bash
    flutter test integration_test/ -d "iPhone 16 Pro"
    ```
