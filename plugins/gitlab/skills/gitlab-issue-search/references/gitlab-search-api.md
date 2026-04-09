# GitLab Search API リファレンス

## 概要

GitLab Search APIは、プロジェクトまたはグループ内のイシューを全文検索するためのAPIである。`glab_issue_list --search` では不十分な場合（イシュー本文の全文検索、コメント内テキストの検索等）に `glab_api` を使用する。

## プロジェクト内検索

**エンドポイント:** `GET /projects/:id/search`

```
glab_api args: ["projects/<encoded_project>/search"]
  flags:
    method: "GET"
    raw_field:
      - "scope=issues"
      - "search=<query>"
      - "per_page=20"
```

### パラメータ

- `scope` - 検索スコープ。イシュー検索には `issues` を指定する。
- `search` - 検索クエリ文字列。
- `per_page` - 1ページあたりの件数（最大100、デフォルト20）。
- `page` - ページ番号（デフォルト1）。
- `state` - イシュー状態フィルタ（`opened`, `closed`）。
- `confidential` - 機密イシューフィルタ（`true`/`false`）。

### レスポンス構造

各イシューには以下が含まれる：
- `id` - イシューID
- `iid` - プロジェクト内イシューIID
- `title` - タイトル
- `description` - 説明文
- `state` - 状態（`opened`/`closed`）
- `labels` - ラベル配列
- `assignees` - 担当者配列
- `author` - 作成者
- `created_at` - 作成日時
- `updated_at` - 更新日時
- `web_url` - Web URL

## グループ横断検索

**エンドポイント:** `GET /groups/:id/search`

```
glab_api args: ["groups/<encoded_group>/search"]
  flags:
    method: "GET"
    raw_field:
      - "scope=issues"
      - "search=<query>"
      - "per_page=20"
```

グループ内の全プロジェクトを横断してイシューを検索する。パラメータとレスポンスはプロジェクト内検索と同様。

## glab_issue_list の検索パラメータ詳細

`glab_issue_list` はMCPサーバー経由で使用でき、以下のフィルタが利用可能：

| フラグ | 説明 | 例 |
|--------|------|-----|
| `--search "<query>"` | タイトル・説明文のテキスト検索 | `--search "login error"` |
| `--in "<field>"` | 検索対象フィールド（`title`, `description`） | `--in "title"` |
| `--label "<label>"` | ラベルフィルタ（複数指定可） | `--label "bug" --label "P1"` |
| `--not_label "<label>"` | ラベル除外フィルタ | `--not_label "wontfix"` |
| `--assignee "<user>"` | 担当者フィルタ | `--assignee "john"` |
| `--not_assignee "<user>"` | 担当者除外フィルタ | `--not_assignee "bot"` |
| `--author "<user>"` | 作成者フィルタ | `--author "alice"` |
| `--not_author "<user>"` | 作成者除外フィルタ | `--not_author "bot"` |
| `--milestone "<name>"` | マイルストーンフィルタ | `--milestone "v2.0"` |
| `--group "<group>"` | グループ横断検索 | `--group "my-org"` |
| `--closed` | クローズ済みイシューを含める | `--closed` |
| `--confidential` | 機密イシューのみ | `--confidential` |
| `--order "<field>"` | ソートキー（`created_at`, `updated_at`, `priority`） | `--order "updated_at"` |
| `--sort "<dir>"` | ソート順（`asc`, `desc`） | `--sort "desc"` |
| `--output "json"` | JSON形式で出力 | `--output "json"` |
| `--per_page <n>` | 1ページあたりの件数 | `--per_page 50` |
| `--page <n>` | ページ番号 | `--page 2` |

## 検索クエリのベストプラクティス

1. **短いキーワードを使用する** — 長い文章より2-3単語のキーワードが効果的。
2. **固有名詞を優先する** — エラーコード、関数名、コンポーネント名は検索精度が高い。
3. **段階的に絞り込む** — まず広い検索で概要を把握し、フィルタで絞り込む。
4. **クローズ済みも検索する** — 過去に解決された類似問題が参考になることが多い。
5. **ラベルと組み合わせる** — テキスト検索とラベルフィルタの組み合わせが最も効果的。

## エラーハンドリング

- **400 Bad Request**: 検索クエリが空または無効。最低1文字以上のクエリが必要。
- **404 Not Found**: プロジェクトまたはグループのパスが正しくURLエンコードされているか確認する。
- **403 Forbidden**: 認証されたユーザーがこのプロジェクト/グループにアクセスする権限を持っていない可能性がある。
