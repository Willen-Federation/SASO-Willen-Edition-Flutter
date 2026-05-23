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

## 3. ユーザー名 / パスワードログイン (`/auth/start/`)

サーバー側の `/auth/start/` の `<form action>` が絶対パスに固定されており、
これが**正規エンドポイント**です。末尾スラッシュ重要 — 新しいデプロイ
では失敗時のリダイレクトが `auth/start/error/1/` 形式に統一されています
（古いデプロイでは `/error/1/`）。

```bash
curl -i -X POST \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'id=USERNAME&password=PASSWORD' \
  https://saso.example.com/auth/start/
```

**期待**: `HTTP/1.1 200 OK` か `302 Found` / `303 See Other` と `Set-Cookie: …`
ヘッダー。Flutter はこのセッション Cookie で以後のリクエストを認証します。

| 結果 | 解釈 |
|---|---|
| 200/302/303 + `Set-Cookie` + 成功 `Location` | サーバーは想定どおり動いている |
| 303 + `Location: /error/...` | **認証情報が間違っている**。サーバーは 303 でエラーページにリダイレクトして失敗を示すため、`PHPSESSID` 等の Cookie は付与されていても認証はしていない。Flutter 側は「the username or password is likely incorrect」と表示する |
| 200/302/303 だが `Set-Cookie` 無し（かつ Location も非エラー） | サーバーが JWT を JSON で返している可能性。新エンドポイント (`/api/v1/auth/login` 相当) への移行が必要 |
| 401 | 認証情報が間違っている。サーバー側のユーザー DB を確認 |
| 404 | サーバーが `/auth/start/` 未実装。極めて古い SASO の可能性 |
| 5xx | サーバー側エラー |

> **注**: `curl` でログインを叩く場合は `-L`（リダイレクト追跡）を **付けないこと**。
> 付けると失敗時の 303 を追跡してエラーページの 404 だけが見え、本当の挙動が隠れます。
> Flutter クライアント側は `http.Request.followRedirects = false` で 3xx を直接観測しています。
> 失敗時の `Location` は `/error/...`（古いデプロイ）または `/auth/start/error/...`（新しいデプロイ）のいずれかになります。

---

## 4. クライアントログの読み方

`flutter run` 中 (もしくは実機で `flutter logs`) に以下のキーワードを grep。

```text
[AuthDiscovery] GET …/api/v1/auth/providers failed: …
[AuthDiscovery] GET …/api/v1/auth/providers returned HTTP 404: …
[AuthDiscovery] could not parse response from …
```

これらが出ている場合は Discovery がフォールバックしている=サーバー側 API が
未整備。出ていないのにログインに失敗するなら `/auth/start/` 側の問題。

---

## 5. 切り分けマトリクス

| `/api/v1/health` | `/api/v1/auth/providers` | `/auth/start/` | 推定原因 |
|:---:|:---:|:---:|---|
| 200 | 200 | 200/302/303+Cookie | クライアントバグ。ログ全文を添えて報告 |
| 200 | 200 | 401 | 認証情報誤り |
| 200 | 200 | 303 → `/error/...` または `/auth/start/error/...` | 認証情報誤り（新デプロイで `/auth/start/error/...` に統一） |
| 200 | 200 | 200 / no Cookie | サーバーが Cookie 名/フォーマットを変更。要すり合わせ |
| 200 | 500 (SASO-INFRA-9000) | 303 → `/error/...` | サーバーの `APP_KEY` が prod `.env` に未設定で Discovery が起動失敗 → クライアントは無音で `localOnly` フォールバック。認証情報誤りは別問題。`SASO-INFRA-9000` の `traceId` を運用に渡せばサーバー側で特定可能 |
| 200 | 404 | 200/303+Cookie | Discovery 未デプロイ。フォールバック動作で実害はないがログが汚れる |
| 404 | 404 | 200+Cookie | サーバーが M3 未対応。Flutter クライアントは現状この URL では運用不可 |
| 接続不可 | 接続不可 | 接続不可 | URL/ネットワーク/証明書の問題。サーバー側の問題ではない |
