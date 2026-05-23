# タブレット / 折りたたみデバイス レイアウト検証ノート

Issue: [#159 [F20] タブレット / 折りたたみデバイス レイアウト検証](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/159)
Parent Epic: [#139](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/139)
Blocked by: [#158 [F19] SliverGrid を adaptiveColumns 対応](https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues/158)

本ノートは静的解析ベースの初期監査結果と、実機検証の手順 / 担当者向け作業リストをまとめたものです。
スクリーンショット取得と崩れの実証は実機 (Pixel Tablet / Pixel Fold) を要するため、本 PR の範囲外です。

---

## 検証スコープ

### 対象デバイス

| デバイス | 画面 | sw (smallest width) | 想定姿勢 |
|--------|--------|---------------------|---------|
| Pixel Tablet | 10.95" / 1600×2560 | sw800dp | 横向き常用 |
| Pixel Fold (cover) | 5.8" / 1080×2092 | sw412dp | 縦向き (通常スマホと同等) |
| Pixel Fold (unfold) | 7.6" / 2208×1840 | sw673dp | 横/縦両対応 |
| 通常スマホ landscape | 6.1" / 横向き回転 | sw360dp 前後 | 一時的な横向き |

### 既存リソース

- `lib/presentation/layout/responsive.dart` — `Breakpoints` (600/1024), `Responsive`, `AdaptiveContainer`, `TwoPaneScaffold` がすでに用意されている。
- `android/app/src/main/AndroidManifest.xml:35` — `configChanges` に `screenLayout` / `density` 含む（受け入れ条件 1 つは満たし済み）。
- 現状 `Responsive` ヘルパーを参照しているのは定義ファイル自身のみ。`#158 (F19)` が完了するとホーム画面以降で参照されるようになる予定。

---

## 静的解析結果 — ページ別所見

各ページのソースを読み、**実機検証で確認すべき仮説** を洗い出しました。実際に崩れが発生するかは実機検証次第で、ここでは「怪しい箇所」のリストです。

### `splash_page.dart`
- ロゴ `width: 240` を直接指定 (l.67)。Pixel Tablet の 1600px 幅では小さく見える可能性。
- **検証ポイント**: タブレットでロゴが極端に小さく感じないか。必要なら `Responsive.of(context)` でサイズ切り替え。

### `getting_started_page.dart` (オンボーディング)
- `EdgeInsets.symmetric(horizontal: 32, vertical: 40)` (l.134)。タブレットでも 32px のみだと余白がスカスカに見える可能性。
- **検証ポイント**: `AdaptiveContainer` (`maxContentWidth: 640`) でコンテンツ幅を中央寄せに制限すべきか。

### `login_page.dart`
- `EdgeInsets.all(24)` (l.207) のみで `ConstrainedBox` / `maxWidth` なし。
- **検証ポイント (Issue 本文記載)**: タブレットで文字幅が長すぎ問題。`AdaptiveContainer` で幅を 480〜600px にキャップすると良さそう。

### `qr_pairing_page.dart`
- QR コード表示部分の中央寄せ + サイズ調整は実機確認が必要。
- アイコン `size: 48` のみ確認できたが QR 本体のサイズ指定は実装次第。
- **検証ポイント**: タブレットで QR が画面中央に表示され、過大化していないか。

### `mobile_setup_webview_page.dart` / `saml_webview_page.dart` (WebView)
- WebView 側のレスポンシブ対応はサーバー側 HTML に依存。Flutter 側からは `initialScale` / `useWideViewPort` あたりの設定確認が必要。
- **検証ポイント**: 横向き / 縦向きで WebView コンテンツが破綻しないか。

### `home_page.dart`
- `SliverGrid.count(crossAxisCount: 2)` (l.76) のハードコード。
- **検証ポイント**: F19 (#158) で `Responsive.adaptiveColumns()` 化される予定。本 Issue では F19 完了後に再検証。

### `item_search_page.dart`
- `ListView.builder` (l.340) — 単一カラムリスト。
- **検証ポイント**: タブレット横向き / Fold unfold で 2 カラムグリッド化を検討する余地あり。

### `item_detail_page.dart`
- `ListView` (l.74, l.195) — 単一カラム。
- **Issue 本文記載**: タブレットでは Master-Detail 検討 — `TwoPaneScaffold` の活用余地あり (master: 検索結果、detail: アイテム詳細)。

### `item_edit_page.dart`
- 編集フォーム。幅が広いタブレットで入力欄が画面いっぱいに広がると視線移動が大きくなる懸念。
- **検証ポイント**: `AdaptiveContainer(maxWidth: 600)` 相当で中央寄せにすべきか。

### `item_register_page.dart` (921 行)
- `ImagePicker.maxWidth: 1280` は撮影画像のリサイズで UI とは無関係。
- 各フィールドはモバイル前提の単一カラム。
- **Issue 本文記載**: 折りたたみ unfold 時の二列化検討。`Responsive.isAtLeastTablet` 分岐で 2 カラム化 (左: 基本情報、右: 画像 + 詳細) の検討余地。

### `inventory_adjust_page.dart`
- 数量調整 UI。タブレットでボタンが小さく中央に固まる可能性。

### `location_list_page.dart` / `shelf_view_page.dart` / `category_browser_page.dart`
- 階層ナビゲーション系。タブレットでは Master-Detail (左ペイン: 階層、右ペイン: 詳細リスト) が UX 向上。

### `barcode_scanner_page.dart`
- `MobileScanner` の上に固定 `width: 240, height: 240` のスキャンオーバーレイ (l.160-161)。
- **Issue 本文記載 (カメラプレビューのアスペクト比)**: `MobileScanner` 自体は `mobile_scanner` package のデフォルト動作。タブレット横向きで上下にレターボックスが出ないか実機確認。
- **検証ポイント**: スキャンオーバーレイをタブレットで `min(width, height) * 0.35` あたりに動的化すると良いかも。

### `outbox_page.dart`
- 送信キューリスト。単一カラムで問題ないが、タブレットでは中央寄せ + maxWidth 制限を検討。

### `server_settings_page.dart`
- 設定フォーム。タブレットで入力欄が画面いっぱいに広がる懸念は login_page と同様。

---

## 受け入れ条件の進捗

- [ ] **各ページのスクリーンショット** — 実機 (Pixel Tablet / Pixel Fold unfold / Phone Landscape) 必要、本 PR では未実施。
- [ ] **UI 崩れ箇所をリスト化、別 Issue 化** — 上記静的解析の「検証ポイント」を実機検証で確定後、サブ Issue を切る予定。
- [x] **AndroidManifest.xml の `configChanges` で `screenLayout` / `density` 確認** — `android/app/src/main/AndroidManifest.xml:35` で含まれている。
- [ ] (Optional) **WindowManager Jetpack for foldable posture detection** — Flutter 側からは `flutter_foldable` / `dual_screen` package、もしくは MethodChannel で `WindowInfoTracker` を呼ぶ方式を検討。本 Issue 範囲外。
- [ ] (Optional) **`MediaQuery.size` を直接見ているコードを `LayoutBuilder` 経由に統一** — `lib/presentation/pages/` 配下に直接参照は現状 **なし**。すでに `MediaQuery.sizeOf(context)` は `responsive.dart` でのみ使用。

---

## 実機検証の手順

実機検証担当向けの手順メモです。

### 1. 環境準備

```bash
# Pixel Tablet エミュレータ
flutter emulators --launch Pixel_Tablet_API_34

# Pixel Fold エミュレータ
flutter emulators --launch Pixel_Fold_API_34
```

または、Android Studio Device Manager から `Pixel Tablet` / `Pixel Fold` AVD を作成。

### 2. 検証フロー (各デバイスで実施)

1. アプリ起動 (`flutter run -d <device_id>`)
2. 上記 18 ページを順に開く
3. スクリーンショット取得 (`adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png`)
4. 崩れている箇所をマーカーで囲んで PR コメントに添付

### 3. 折りたたみ姿勢検証 (Pixel Fold のみ)

```bash
# cover (folded) → unfolded への切り替え
adb shell cmd window unfold
adb shell cmd window fold

# 半開き (half-folded) — table-top mode
adb shell cmd window posture half-opened
```

### 4. 横向き検証 (通常スマホ)

```bash
adb shell settings put system accelerometer_rotation 0
adb shell settings put system user_rotation 1  # 1 = 90度 (landscape)
```

---

## 関連 Issue

- 本 Issue (#159) で実機検証後、ページ別の修正 Issue を切る。
- F19 (#158) 完了待ち: `home_page` のグリッド化検証は F19 完了後にやり直し。

---

## 参考リンク

- [Build for foldables](https://developer.android.com/guide/topics/large-screens/learn-about-foldables)
- [Play Store: Large screen quality guidelines](https://developer.android.com/quality/large-screens)
- [WindowManager Jetpack](https://developer.android.com/jetpack/androidx/releases/window)
- [Flutter: Adaptive design](https://docs.flutter.dev/ui/adaptive-responsive)
