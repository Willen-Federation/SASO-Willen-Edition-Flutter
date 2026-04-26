# コントリビューション

SASO Willen Edition Flutter へのコントリビューションを歓迎します！

> 完全なガイドはリポジトリルートの [CONTRIBUTING.md](https://github.com/willen-federation/saso-willen-edition-flutter/blob/main/CONTRIBUTING.md) を参照してください。

---

## 開発環境のセットアップ

```bash
# 1. リポジトリをフォーク・クローン
git clone https://github.com/<your-name>/saso-willen-edition-flutter.git
cd saso-willen-edition-flutter

# 2. 依存パッケージを取得
make setup   # flutter pub get

# 3. コード生成（freezed, riverpod_annotation, go_router）
make gen     # dart run build_runner build --delete-conflicting-outputs

# 4. テストを実行
make test    # ユニット + ウィジェットテスト
```

---

## ブランチ命名規則

| プレフィックス | 用途 |
|--------------|------|
| `feature/` | 新機能 |
| `fix/` | バグ修正 |
| `chore/` | ビルド・ドキュメント・リファクタリング |

例: `feature/sns-pinpoint-production`

---

## コミットメッセージ

[Conventional Commits](https://www.conventionalcommits.org/) 形式を使用：

```
feat: FCM プロダクション実装（トークンリフレッシュ対応）
fix: SnsPushService で Amplify.configure() が呼ばれていないバグを修正
docs: README にクイックスタートを追加
chore: flutter 3.29.3 へ更新
```

---

## PR マージ条件

PR をマージするには以下をすべて満たす必要があります：

- [ ] `make fmt` — コードフォーマット
- [ ] `make analyze` — 静的解析（警告なし）
- [ ] `make test` — ユニット + ウィジェットテスト全通過
- [ ] domain / data レイヤーのカバレッジ 80% 以上
- [ ] セキュリティポリシー遵守（`flutter_secure_storage` のみで認証情報を保存）

---

## ライセンス

このプロジェクトは **GPL-3.0** ライセンスです。  
コントリビューションを送ることで、あなたのコードが GPL-3.0 でライセンスされることに同意したものとみなします。
