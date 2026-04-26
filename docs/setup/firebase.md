# Firebase セットアップ

FCM プッシュ通知・Firebase Authentication を有効にするためのガイドです。  
**コードの編集は不要です。** 設定ファイルを所定の場所に置くだけで完了します。

---

## 前提条件

- Google アカウント
- [Firebase Console](https://console.firebase.google.com/) へのアクセス権

---

## 手順

### 1. Firebase プロジェクトを作成

1. [Firebase Console](https://console.firebase.google.com/) を開く
2. **「プロジェクトを追加」** をクリック
3. プロジェクト名を入力（例: `saso-willen`）
4. Google アナリティクスは任意で設定

### 2. iOS アプリを登録

1. Firebase コンソール左上の **「アプリを追加」→「iOS+」** を選択
2. **バンドル ID** に `jp.willen.saso` を入力（`ios/Runner.xcodeproj` の設定と一致させること）
3. **「アプリを登録」** をクリック
4. **`GoogleService-Info.plist`** をダウンロード

    ```
    ダウンロードしたファイルを以下の場所に配置：
    ios/Runner/GoogleService-Info.plist
    ```

5. 「次へ」を繰り返してウィザードを完了（SDK の追加コードは不要）

!!! warning "注意"
    `GoogleService-Info.plist` は **絶対に Git にコミットしないでください。**  
    `.gitignore` に既に追加されています。

### 3. Android アプリを登録

1. **「アプリを追加」→「Android」** を選択
2. **パッケージ名** に `jp.willen.saso` を入力
3. **「アプリを登録」** をクリック
4. **`google-services.json`** をダウンロード

    ```
    ダウンロードしたファイルを以下の場所に配置：
    android/app/google-services.json
    ```

!!! warning "注意"
    `google-services.json` も **Git にコミットしないでください。**

### 4. FCM プッシュ通知を有効化

=== "iOS"

    1. [Apple Developer Console](https://developer.apple.com) で **APNs 認証キー（.p8）** を生成
        - **証明書、ID & プロファイル → キー → +**
        - **Apple Push Notifications service (APNs)** にチェック
        - キーをダウンロード（**1 回のみ**）
    2. Firebase コンソール → プロジェクト設定 → **「Cloud Messaging」タブ**
    3. **「APNs 認証キー」** セクションで `.p8` ファイルをアップロード
    4. **キー ID** と **チーム ID** を入力

=== "Android"

    Android は `google-services.json` を配置するだけで FCM が有効になります。  
    追加の証明書設定は不要です。

### 5. Firebase Remote Config を有効化（フィーチャーフラグ用）

1. Firebase コンソール → **「Remote Config」** を開く
2. **「構成を作成」** をクリック
3. 以下のパラメータを追加：

    | パラメータキー | 型 | デフォルト値 |
    |--------------|-----|------------|
    | `ff_push_fcm` | Boolean | `true` |
    | `ff_push_sns` | Boolean | `false` |
    | `ff_auth_oidc` | Boolean | `true` |
    | `ff_auth_firebase` | Boolean | `true` |
    | `ff_offline_mode` | Boolean | `true` |
    | `ff_barcode_scanner` | Boolean | `true` |
    | `ff_rest_api_v1` | Boolean | `false` |
    | `ff_label_print` | Boolean | `false` |

4. **「変更を公開」** をクリック

---

## 確認

設定ファイルを配置したら実機でビルドしてください：

```bash
flutter run --release
```

FCM トークンはアプリ起動時にコンソールログに出力されます（デバッグビルドのみ）。

---

## トラブルシューティング

??? failure "`GoogleService-Info.plist` が見つからないエラー"
    `ios/Runner/` ディレクトリに直接配置されているか確認してください。  
    Xcode でも **Runner グループ** に追加されている必要があります：  
    Xcode → Runner → Runner グループを右クリック →「Add Files to "Runner"」

??? failure "Android ビルドで `google-services.json` エラー"
    `android/app/` ディレクトリに配置されているか確認してください。  
    `android/` ではなく `android/app/` が正しい場所です。
