# バージョニング規約 / Versioning policy

このドキュメントは SASO Willen Edition (Flutter) のリリース時に従う
バージョニング規約と、iOS / Android 側のビルド設定の単一情報源
(single source of truth) を定義する。Issue #138 で確定。

This document defines the versioning policy followed when releasing SASO
Willen Edition (Flutter), and identifies the single source of truth for
version-related build settings on both iOS and Android. Finalised in
Issue #138.

---

## 単一情報源 / Single source of truth

バージョンは **`pubspec.yaml`** にのみ書く。

```yaml
# pubspec.yaml
version: 1.0.0+1
#         ^^^^^ ^
#         |     +-- build number   → CFBundleVersion          / versionCode
#         +-------- marketing ver. → CFBundleShortVersionString / versionName
```

Flutter のビルドプロセスは pubspec の値を以下の Xcode/Gradle 変数として
注入する。**pbxproj / build.gradle に静的な値を書いてはならない。**

| プラットフォーム | 注入先 (build var)        | 反映先 (実値)                      |
| ---------------- | ------------------------- | ---------------------------------- |
| iOS              | `FLUTTER_BUILD_NAME`      | `MARKETING_VERSION` → `CFBundleShortVersionString` |
| iOS              | `FLUTTER_BUILD_NUMBER`    | `CURRENT_PROJECT_VERSION` → `CFBundleVersion`      |
| Android          | `flutter.versionName`     | `versionName`                      |
| Android          | `flutter.versionCode`     | `versionCode`                      |

iOS 側は `ios/Runner/Info.plist` が `$(FLUTTER_BUILD_NAME)` と
`$(FLUTTER_BUILD_NUMBER)` を直接参照しており、pbxproj 内の
`MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` も同じ Flutter 変数を経由
する形に統一されている (Issue #138)。

---

## セマンティック・バージョニング / Semantic versioning

`MAJOR.MINOR.PATCH+BUILD` の形式で SemVer 2.0.0 に準拠する。

- **MAJOR** — 後方互換性のない大規模変更 (例: API モード v3 移行完了、
  Riverpod 3 移行、認証フロー全面刷新)。
- **MINOR** — 後方互換性のある機能追加 (例: 新スキャンモード、新言語、
  新 API エンドポイント対応)。
- **PATCH** — バグ修正、ドキュメント、軽微な UI 調整、内部リファクタ。
- **+BUILD** — App Store / Play Store への提出ごとに **必ず +1**
  (同じ `MAJOR.MINOR.PATCH` でも再提出時はインクリメント)。

### 例

| 変更内容                                       | 次のバージョン      |
| ---------------------------------------------- | ------------------- |
| 初回 App Store / Play Store 提出               | `1.0.0+1`           |
| 同バージョンの再提出 (リジェクト対応含む)      | `1.0.0+2`           |
| バグ修正リリース                               | `1.0.1+3`           |
| 新機能追加 (機能フラグ込み)                    | `1.1.0+4`           |
| ApiMode.legacy 完全削除 (v3.0、破壊的変更)    | `2.0.0+N`           |

### ビルド番号 (`+BUILD`) のルール

- **単調増加** — 一度上げたら絶対に下げない (App Store Connect / Play
  Console が拒否する)。
- リリースブランチをまたいでも連番を維持する。`git tag` の最新の `+N`
  を確認してから次の値を決める。
- ローカル開発・CI のテストビルドではビルド番号を上げる必要はない。
  ストア提出が確定したタイミングで `pubspec.yaml` を編集する。

---

## iOS Deployment Target

**現状: `IPHONEOS_DEPLOYMENT_TARGET = 15.5` (維持)**

- iOS 15.5 は iPhone 6s (2015) 以降をサポート。業務用ハンディターミナル
  用途として広範な端末カバレッジが必要なため維持する。
- `mobile_scanner 7.x` (AVFoundation / Vision) は iOS 15.0+ を要求する
  ため 15.5 で十分。
- ストア要件としては iOS 16+ が一般的だが、Apple の現行ポリシーは
  iOS 14+ 程度のサポートで十分審査通過する (2025-2026 時点)。
- 引き上げを検討する条件: 主要な依存ライブラリのいずれかが iOS 16+ を
  要求した場合、または iOS 15.x シェアが 1% を切った場合。

設定は以下 3 箇所に存在する (3 箇所すべて同じ値で揃える):

- `ios/Runner.xcodeproj/project.pbxproj` の `PBXProject` 配下の Debug /
  Release / Profile 配置 (現在は L458 / L588 / L639)
- `ios/Podfile` の `platform :ios, '15.5'` (L2)
- `ios/Flutter/AppFrameworkInfo.plist` の `MinimumOSVersion` (もし
  Flutter SDK 側で書き換えられたら同期する)

---

## Android targetSdk / minSdk

参考値 (詳細は `android/app/build.gradle` を参照):

- `minSdkVersion` — Flutter デフォルト (現状 21 / Android 5.0)。
  `pubspec.yaml` の `flutter_launcher_icons.min_sdk_android: 21` と整合。
- `targetSdkVersion` — Flutter デフォルト。Play Console の要求に追従する。

---

## リリース手順 / Release procedure

1. **バージョン bump** — `pubspec.yaml` の `version:` を更新し、PR で
   レビューする。
2. **CHANGELOG 更新** — `CHANGELOG.md` (および `docs/changelog.md`) に
   今回のバージョン節を追加。`Keep a Changelog` 形式に従う。
3. **タグ付け** — main マージ後 `git tag v1.0.0+1` を打ち、`git push
   --tags`。CI のリリースワークフロー (もしあれば) が動く。
4. **ストア提出** — App Store Connect / Play Console にバイナリを
   アップロード。
5. **次のサイクル** — リリース完了後、すぐに `pubspec.yaml` を次の
   開発用 SNAPSHOT (例 `1.0.1+2`) に上げない。次の bump 時に
   インクリメントする運用にする (タグと pubspec の値を一致させやすい)。

---

## 関連 Issue / Related issues

- #120 — App Store v1.0 リリース準備 (親 Epic)
- #138 — iOS Deployment Target & アプリバージョン戦略決定 (本ドキュメント)
