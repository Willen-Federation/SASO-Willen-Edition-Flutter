# ログインが失敗するときの切り分け

端末から SASO サーバーにログインしようとしたとき、画面に
`Authentication failed (HTTP …)` や `接続できませんでした: …` が出る場合の
切り分け手順です。

クライアント側 (Flutter) は失敗時に HTTP ステータスと応答本文の冒頭をログイン
画面に表示し、Discovery の失敗は `flutter logs` の `[AuthDiscovery]` 行に
吐き出します。まずは画面メッセージとログを確認したうえで、以下の curl で
サーバー側の状態を直接確認してください。

`https://saso.example.com` を実際のサーバー URL に置き換えて実行します。

---

## 1. ヘルスチェック (オンボーディング接続テストが叩く)

```bash
curl -i https://saso.example.com/api/v1/health
```

**期待**: `HTTP/1.1 200 OK` と JSON `{"status":"ok"}`。

| 結果 | 解釈 |
|---|---|
| 200 + `{"status":"ok"}` | サーバーの v1 API は生きている。次の項に進む |
| 404 | サーバーがまだ M3 (`/api/v1/*`) を実装していない。Flutter は現状この URL では使えない |
| 5xx | サーバー側エラー。サーバーログを確認 |
| 接続不可 / DNS 失敗 | URL ミス、社内ネットワーク制限、TLS 証明書不正のいずれか |

---

## 2. 認証プロバイダー Discovery (スプラッシュが叩く)

```bash
curl -i -H 'Accept: application/json' \
  https://saso.example.com/api/v1/auth/providers
```

**期待**: 200 と `serverName / version / mobileSetupUrl / authStrategy / providers[]` を含む JSON。
[docs/api/openapi.yaml](../api/openapi.yaml) の `AuthProviderDiscovery` 参照。

| 結果 | 解釈 |
|---|---|
| 200 + 期待 JSON | ログイン画面に正しい選択肢が出る。次の項に進む |
| 200 だが JSON 形が違う | サーバーが古い形 (`{provider, config}` 等) を返している。サーバー側の Discovery 実装を v1 に揃える必要あり |
| 404 | サーバーが Discovery 未実装。クライアントは無音で `localOnly` フォールバックに落ちる (Flutter 側 `[AuthDiscovery]` ログで確認可能) |
| 200 だが `providers: []` | サーバー設定で有効な IdP が無い。フォールバックでローカルログインだけ出る |

---

## 3. ユーザー名 / パスワードログイン (`/auth/start`)

```bash
curl -i -X POST \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'id=USERNAME&password=PASSWORD' \
  https://saso.example.com/auth/start
```

**期待**: `HTTP/1.1 200 OK` か `302 Found` と `Set-Cookie: …` ヘッダー。Flutter は
このセッション Cookie で以後のリクエストを認証します。

| 結果 | 解釈 |
|---|---|
| 200/302 + `Set-Cookie` | サーバーは想定どおり動いている。クライアントが「Authentication failed (HTTP 200) Set-Cookie 無し」を出すなら Cookie 名を確認 |
| 200/302 だが `Set-Cookie` 無し | サーバーが JWT を JSON で返している可能性。新エンドポイント (`/api/v1/auth/login` 相当) への移行が必要 |
| 401 | 認証情報が間違っている。サーバー側のユーザー DB を確認 |
| 404 | サーバーが `/auth/start` 未実装。レガシー側だけ存在する想定が崩れている |
| 5xx | サーバー側エラー |

---

## 4. クライアントログの読み方

`flutter run` 中 (もしくは実機で `flutter logs`) に以下のキーワードを grep。

```text
[AuthDiscovery] GET …/api/v1/auth/providers failed: …
[AuthDiscovery] GET …/api/v1/auth/providers returned HTTP 404: …
[AuthDiscovery] could not parse response from …
```

これらが出ている場合は Discovery がフォールバックしている=サーバー側 API が
未整備。出ていないのにログインに失敗するなら `/auth/start` 側の問題。

---

## 5. 切り分けマトリクス

| `/api/v1/health` | `/api/v1/auth/providers` | `/auth/start` | 推定原因 |
|:---:|:---:|:---:|---|
| 200 | 200 | 200+Cookie | クライアントバグ。ログ全文を添えて報告 |
| 200 | 200 | 401 | 認証情報誤り |
| 200 | 200 | 200 / no Cookie | サーバーが Cookie 名/フォーマットを変更。要すり合わせ |
| 200 | 404 | 200+Cookie | Discovery 未デプロイ。フォールバック動作で実害はないがログが汚れる |
| 404 | 404 | 200+Cookie | サーバーが M3 未対応。Flutter クライアントは現状この URL では運用不可 |
| 接続不可 | 接続不可 | 接続不可 | URL/ネットワーク/証明書の問題。サーバー側の問題ではない |
