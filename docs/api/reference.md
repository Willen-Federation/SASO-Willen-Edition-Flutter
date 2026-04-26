# REST API v1 リファレンス

SASO M3 リリースで提供される REST API v1 (`/api/v1/*`) の仕様書です。
Flutter アプリでは `ff_rest_api_v1` フィーチャーフラグが ON のときに使用されます。

!!! info "認証"
    全エンドポイントは Bearer JWT (RS256, 15 分有効) で認証されます。
    モバイルアプリ側は [サーバー設定ページ](../setup/firebase.md) で取得・保存します。

!!! warning "ステータス"
    M3 リリース前のため、本仕様は **設計時点** のスナップショットです。
    実装側 ([rest_api_client.dart](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/blob/main/lib/data/datasources/remote/v1/rest_api_client.dart)) と齟齬がある場合は実装が正です。

---

## OpenAPI 3.0 仕様書ダウンロード

[`openapi.yaml`](openapi.yaml){ download="saso-rest-api-v1.openapi.yaml" } をダウンロードして、Postman / Insomnia / OpenAPI Generator にインポートできます。

---

## 対話的リファレンス

!!swagger openapi.yaml!!
