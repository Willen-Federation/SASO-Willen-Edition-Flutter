# App Privacy 栄養ラベル — SDK データ収集マッピング

App Store Connect の **App Privacy (栄養ラベル)** へ提出する内容を、組み込み
SDK 単位で網羅したマッピング表です。App Store Review Guideline 5.1.2 / 5.1.3
が要求する「収集する個人データの正確な申告」に対応します。実態と異なる申告は
審査でリジェクト対象となるため、SDK 追加・更新時は本ファイルを必ず同期更新し
てください。

- 親 Issue: [#120 — App Store v1.0 リリース準備][issue-120]
- 直接の発信元: [#123 — App Privacy 栄養ラベル用 SDK データ収集マッピング][issue-123]
- 関連 Issue: [#122 — プライバシーポリシー公開][issue-122] (本書と整合)
- 最終更新: 2026-05-24 (`pubspec.yaml` 0.1.0+1 時点)

[issue-120]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/120
[issue-122]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/122
[issue-123]: https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/123

## 用語

| 用語 | 意味 |
|---|---|
| **収集** (Collected) | アプリのプロセス外 (= SDK の運営事業者のサーバー) に送信される個人データ。デバイス内に留まるデータは「未収集」扱い。 |
| **第三者送信** | Apple が定義する Data SDK Partner (Google / AWS / Auth0 等) への送信。本アプリの自社サーバー (`saso.sksl.jp`) は「自社利用」扱い。 |
| **リンク** (Linked to User) | ユーザー個人を識別可能な形でデータを保持・送信。 |
| **トラッキング** (Used for Tracking) | App Tracking Transparency (ATT) 対象となるクロスアプリ / クロスサイトの追跡。**本アプリは一切実施しない。** |

## サマリ: 本アプリの方針

| App Privacy 区分 | 結論 |
|---|---|
| **Data Used to Track You** | 該当なし (App Tracking Transparency プロンプト不要) |
| **Data Linked to You** | あり: 認証情報・識別子・通知トークン (社内倉庫業務上、ユーザー識別は必須) |
| **Data Not Linked to You** | なし (本アプリは匿名計測 SDK を導入していない) |

「Analytics」「Product Personalization」「Advertising」目的のデータ収集は
**一切行いません** (Firebase Analytics / Crashlytics / Performance, AWS
Pinpoint Analytics 等は本アプリに組み込まれていません)。ATT プロンプトは
不要です。

## SDK 別マッピング

| # | SDK / 機能 | アプリ内用途 | 収集データ種別 | App Privacy カテゴリ (Apple 分類) | 用途 (Purpose) | リンク | 第三者送信先 |
|---|---|---|---|---|---|---|---|
| 1 | `firebase_core` | Firebase 初期化基盤 (実データ送信なし) | (なし — 初期化のみ) | — | — | — | — |
| 2 | `firebase_auth` | OIDC / Email 認証 (一部運用) | メールアドレス、Firebase UID | Contact Info → Email Address / Identifiers → User ID | App Functionality | Yes | Google (Firebase) |
| 3 | `firebase_messaging` | プッシュ通知配信 (FCM トークン) | FCM デバイストークン、APNs デバイストークン | Identifiers → Device ID | App Functionality | Yes | Google (Firebase) / Apple (APNs) |
| 4 | `firebase_remote_config` | フィーチャーフラグ取得 | インストール ID (Firebase Installations) | Identifiers → Device ID | App Functionality | Yes | Google (Firebase) |
| 5 | `amplify_flutter` | Amplify SDK 基盤 (実データ送信なし) | (なし — 初期化のみ) | — | — | — | — |
| 6 | `amplify_push_notifications_pinpoint` | SNS Pinpoint プッシュ通知配信 | APNs/FCM デバイストークン、Pinpoint エンドポイント ID | Identifiers → Device ID | App Functionality | Yes | AWS (Pinpoint / SNS) |
| 7 | `amplify_auth_cognito` | Cognito ユーザープール認証 | メールアドレス、ユーザー名、Cognito Sub (UUID) | Contact Info → Email Address / Identifiers → User ID | App Functionality | Yes | AWS (Cognito) |
| 8 | `flutter_appauth` | OIDC PKCE Authorization Code Flow | アクセストークン / リフレッシュトークン (IdP から取得) | Identifiers → User ID | App Functionality | Yes | テナント設定の IdP (Auth0 / Cognito / Azure AD 等) |
| 9 | `auth0_flutter` | Auth0 ネイティブ SDK (Universal Login) | メールアドレス、Auth0 user_id、IdP メタデータ | Contact Info → Email Address / Identifiers → User ID | App Functionality | Yes | Auth0 (Okta) |
| 10 | `webview_flutter` | SAML SSO WebView フォールバック | (WebView 内: IdP 認証情報 — アプリは保持しない) | — (WebView の通信は IdP との直接接続) | App Functionality | N/A (アプリは保持しない) | テナント IdP (SAML) |
| 11 | `mobile_scanner` | バーコード/QR スキャン (倉庫業務) | カメラ画像 (デバイス内のみ処理、外部送信なし) | — | App Functionality | — | (なし — オンデバイス処理) |
| 12 | `image_picker` | 商品写真撮影 / 写真ライブラリ選択 | 写真画像 (アプリ自社サーバーへアップロード) | User Content → Photos or Videos | App Functionality | Yes | 自社 (Willen) サーバー `saso.sksl.jp` |
| 13 | `cached_network_image` | 商品画像 HTTP キャッシュ | (キャッシュキー = URL のみ。ユーザー識別子なし) | — | — | — | — |
| 14 | `connectivity_plus` | オフラインバナー表示 | (ネットワーク状態のみ、外部送信なし) | — | — | — | — |
| 15 | `flutter_secure_storage` | Keychain / Keystore でトークン保管 | (デバイス内のみ) | — | — | — | — |
| 16 | `shared_preferences` | アプリ設定 (テーマ / API モード) | (デバイス内のみ) | — | — | — | — |
| 17 | `sqflite` | 商品 / カテゴリのオフラインキャッシュ | (デバイス内のみ) | — | — | — | — |
| 18 | 自社 REST v1 API (`http` 経由) | 商品検索 / 登録 / 更新 / バーコード照会 | ユーザー ID (JWT sub)、商品データ、操作ログ (倉庫業務) | Contact Info / Identifiers / User Content | App Functionality | Yes | 自社 (Willen) サーバー `saso.sksl.jp` |

> **第三者送信先の明示**: Auth0 が Okta 傘下となった以降、データ管轄は Auth0
> (Okta) として申告します。Firebase は Google LLC、Pinpoint / Cognito は
> Amazon Web Services, Inc. を Data SDK Partner として申告します。

## App Store Connect 提出用 最終チェックリスト

App Store Connect → アプリ → **App Privacy** → 「データタイプ」セクション
の入力順に並べた最終確認表です。各項目を YES/NO で回答した上で、紐づく用途
(Purpose) を全て選択してください。

### 1. Contact Info (連絡先情報)

| データタイプ | 収集する? | リンクされる? | トラッキング? | 用途 (Purpose) | 収集元 SDK |
|---|---|---|---|---|---|
| Name | NO | — | — | — | — |
| **Email Address** | **YES** | YES | NO | App Functionality | `firebase_auth`, `amplify_auth_cognito`, `auth0_flutter` |
| Phone Number | NO | — | — | — | — |
| Physical Address | NO | — | — | — | — |
| Other User Contact Info | NO | — | — | — | — |

### 2. Health & Fitness / Financial Info / Location / Sensitive Info

| カテゴリ | 収集する? | 備考 |
|---|---|---|
| Health & Fitness | **NO** | 該当 SDK なし |
| Financial Info | **NO** | 決済機能なし |
| Location (Precise / Coarse) | **NO** | 位置情報 API 未使用 |
| Sensitive Info (人種 / 宗教 / 性的指向等) | **NO** | 該当データなし |

### 3. Contacts / User Content

| データタイプ | 収集する? | リンクされる? | トラッキング? | 用途 | 収集元 SDK |
|---|---|---|---|---|---|
| Contacts | NO | — | — | — | — |
| Emails or Text Messages | NO | — | — | — | — |
| **Photos or Videos** | **YES** | YES | NO | App Functionality | `image_picker` (商品撮影) |
| Audio Data | NO | — | — | — | — |
| Gameplay Content | NO | — | — | — | — |
| Customer Support | NO | — | — | — | — |
| **Other User Content** | **YES** | YES | NO | App Functionality | 自社 API (商品名称・備考等の業務データ) |

> Photos: `image_picker` で取得した画像は自社 REST v1
> (`POST /api/v1/items/drafts`) にアップロードされ商品マスタに紐づきます。
> Apple の定義では「アプリの主要機能を提供するために収集」のため
> "App Functionality" 用途を選択します。

### 4. Browsing History / Search History

| データタイプ | 収集する? | 備考 |
|---|---|---|
| Browsing History | **NO** | Web 履歴の収集はなし |
| Search History | **NO** | 商品検索クエリは自社サーバー内ログのみ。Apple 定義の "Search History" (= ユーザーの一般的な検索行動) には該当しない (5.1.2 ガイドのスコープ外) |

### 5. Identifiers

| データタイプ | 収集する? | リンクされる? | トラッキング? | 用途 | 収集元 SDK |
|---|---|---|---|---|---|
| **User ID** | **YES** | YES | NO | App Functionality | `firebase_auth`, `amplify_auth_cognito`, `auth0_flutter`, `flutter_appauth`, 自社 API (JWT sub) |
| **Device ID** | **YES** | YES | NO | App Functionality | `firebase_messaging` (FCM トークン), `amplify_push_notifications_pinpoint` (Pinpoint Endpoint), `firebase_remote_config` (Installations ID) |
| Advertising Data / IDFA | **NO** | — | — | — | 広告 SDK なし。`AppTrackingTransparency` プロンプト不要 |

### 6. Purchases / Usage Data / Diagnostics

| データタイプ | 収集する? | 備考 |
|---|---|---|
| Purchase History | **NO** | アプリ内課金なし |
| **Product Interaction** | **NO** | Analytics SDK 未導入 (Firebase Analytics / AWS Pinpoint Analytics は組み込みなし) |
| Advertising Data | **NO** | — |
| Other Usage Data | **NO** | — |
| **Crash Data** | **NO** | Crashlytics 未導入 |
| **Performance Data** | **NO** | Firebase Performance 未導入 |
| Other Diagnostic Data | **NO** | — |

> **重要**: Firebase は依存していますが、Analytics / Crashlytics /
> Performance / In-App Messaging は `pubspec.yaml` に **含めていません**
> (`firebase_core` / `_auth` / `_messaging` / `_remote_config` のみ)。
> 申告時にこれらを誤ってチェックしないこと。

### 7. Sensitive Info / Surroundings / Body / Other Data

| データタイプ | 収集する? | 備考 |
|---|---|---|
| Sensitive Info | **NO** | — |
| Environment Scanning (AR 等) | **NO** | — |
| Hands (手) | **NO** | — |
| Head (頭) | **NO** | — |
| Other Data Types | **NO** | — |

## 用途 (Purpose) 別の整理

App Store Connect は最終的に「用途別の集計表」も求めます。本アプリは
**App Functionality のみ** で完結します。

| Purpose | 該当する? | 該当データタイプ |
|---|---|---|
| **Third-Party Advertising** | NO | — |
| **Developer's Advertising or Marketing** | NO | — |
| **Analytics** | NO | (Analytics SDK 未導入) |
| **Product Personalization** | NO | — |
| **App Functionality** | **YES** | Email Address, Photos, Other User Content, User ID, Device ID |
| **Other Purposes** | NO | — |

## トラッキング (ATT) 申告

| 質問 | 回答 |
|---|---|
| アプリは ATT (App Tracking Transparency) フレームワークを使用しますか? | **NO** |
| 他社のアプリ / Web 横断のユーザー追跡を行いますか? | **NO** |
| データブローカーへの提供がありますか? | **NO** |

`Info.plist` への `NSUserTrackingUsageDescription` 追加は **不要** です。
ATT プロンプトを表示する SDK を将来導入する場合は、本書とプライバシーポリシー
([#122][issue-122]) を同時に更新してください。

## DPA / プライバシーポリシーとの整合性

[#122][issue-122] で整備するプライバシーポリシー (`docs/ja/privacy-policy.md`,
`docs/en/privacy-policy.md`) と本書は、以下の対応関係を維持してください。

| プライバシーポリシー記載項目 | 本書の対応箇所 |
|---|---|
| 「収集する個人データの種別」 | SDK 別マッピング表 / Contact Info / Identifiers / User Content |
| 「利用目的」 | "用途 (Purpose) 別の整理" — App Functionality |
| 「第三者提供」 | SDK 別マッピング表「第三者送信先」列 (Google / AWS / Auth0) |
| 「保存期間」 | 別途プライバシーポリシー本文に記載 (本書ではスコープ外) |
| 「ユーザー権利 (削除請求等)」 | プライバシーポリシー本文 + 自社 API のアカウント削除フロー |

各 SDK 事業者の DPA (Data Processing Addendum) は以下を参照:

- Firebase: [firebase.google.com/support/privacy](https://firebase.google.com/support/privacy)
- AWS (Cognito / Pinpoint): [aws.amazon.com/compliance/data-privacy-faq](https://aws.amazon.com/compliance/data-privacy-faq/)
- Auth0 (Okta): [auth0.com/docs/secure/data-privacy-and-compliance](https://auth0.com/docs/secure/data-privacy-and-compliance)
- Apple (APNs): [developer.apple.com/support/terms](https://developer.apple.com/support/terms/)

## メンテナンス手順

新規 SDK を `pubspec.yaml` に追加するとき、または既存 SDK の収集データ
範囲が変わったときは、以下を **同一 PR 内で** 更新してください。

1. 本書 (`docs/release/app-privacy-mapping.md`) の SDK 別マッピング表に行を追加
2. App Store Connect 提出用チェックリストの YES/NO を再評価
3. プライバシーポリシー ([#122][issue-122]) の「第三者提供」節を同期
4. ATT 影響がある場合は `Info.plist` (`NSUserTrackingUsageDescription`) を更新
5. リリース PR 内で `docs/release/app-privacy-mapping.md` の差分を必ず指摘
   する (レビュアー向けの確認ポイント)

## 参考

- [Apple App Privacy Details — the basics](https://developer.apple.com/app-store/app-privacy-details/)
- [App Store Review Guidelines 5.1 (Privacy)](https://developer.apple.com/app-store/review/guidelines/#privacy)
- [User Privacy and Data Use (App Tracking Transparency)](https://developer.apple.com/app-store/user-privacy-and-data-use/)
- [Firebase Data Disclosure](https://firebase.google.com/support/privacy)
- [Auth0 Data Privacy & Compliance](https://auth0.com/docs/secure/data-privacy-and-compliance)
