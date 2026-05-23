# リリースノート / Release notes

本アプリのストア提出と公開に必要な参照 URL と手順をまとめます。
This page collects the URLs and references required when submitting the App to the stores and publishing releases.

---

## App Store / Google Play 提出時の必須 URL

| 項目 | URL |
|---|---|
| プライバシーポリシー（日本語） / Privacy Policy (JA) | <https://saso-willen-flutter.netlify.app/privacy-policy/> |
| Privacy Policy (English) | <https://saso-willen-flutter.netlify.app/en/privacy-policy/> |
| サポート URL（GitHub Issues） | <https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter/issues> |
| マーケティング URL（ドキュメントトップ） | <https://saso-willen-flutter.netlify.app/> |
| ソースコード | <https://github.com/Willen-Federation/SASO-Willen-Edition-Flutter> |

App Store Connect の **「App プライバシー」** および **「アプリ情報 → プライバシーポリシー URL」** に上記日本語ページの URL を登録してください。Google Play Console では **「アプリのコンテンツ → プライバシーポリシー」** に同 URL を登録します。

The Japanese URL above is the canonical URL submitted to App Store Connect ("App Privacy" / "App Information → Privacy Policy URL") and Google Play Console ("App content → Privacy policy"). The English version is available via the same Netlify deployment under the `/en/` prefix.

---

## ドキュメントサイトへの公開

`docs/privacy-policy.md`（日本語）および `docs/privacy-policy.en.md`（英語）は MkDocs Material の `i18n` プラグインで自動的に多言語化され、`main` ブランチへのマージ後に Netlify へ自動デプロイされます。

ローカルでのプレビュー:

```bash
pip install -r requirements.txt
mkdocs serve
# http://127.0.0.1:8000/privacy-policy/ で表示確認
```

---

## 参考 / References

- [App Store Review Guideline 5.1.1 — Data Collection and Storage](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage)
- [App Privacy Details on the App Store](https://developer.apple.com/app-store/app-privacy-details/)
- [Google Play — User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311)
