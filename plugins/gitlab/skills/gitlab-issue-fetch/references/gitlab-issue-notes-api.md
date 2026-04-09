# GitLab Issue Notes API リファレンス

## 概要

GitLab Notes APIは、イシューに投稿されたコメント（ノート）を取得・管理するためのAPIである。`glab_issue_view --comments` では取得できない構造化データやページネーションが必要な場合に `glab_api` を使用する。

## ノート一覧の取得

**エンドポイント:** `GET /projects/:id/issues/:iid/notes`

```
glab_api args: ["projects/<encoded_project>/issues/<iid>/notes"]
  flags:
    method: "GET"
    raw_field:
      - "per_page=100"
      - "page=1"
      - "sort=asc"
      - "order_by=created_at"
```

### パラメータ

- `per_page` - 1ページあたりの件数（最大100、デフォルト20）
- `page` - ページ番号（デフォルト1）
- `sort` - ソート順（`asc` または `desc`、デフォルト `desc`）
- `order_by` - ソートキー（`created_at` または `updated_at`、デフォルト `created_at`）

### レスポンス構造

各ノートには以下が含まれる：
- `id` - ノートID
- `body` - コメント本文（Markdown形式）
- `author` - 投稿者オブジェクト：
  - `author.id` - ユーザーID
  - `author.username` - ユーザー名
  - `author.name` - 表示名
- `created_at` - 作成日時（ISO 8601形式）
- `updated_at` - 更新日時
- `system` - システムノートかどうか（`true`/`false`）
  - `true`: ラベル変更、担当者変更、マイルストーン変更等のシステムイベント
  - `false`: ユーザーが投稿したコメント
- `noteable_id` - 関連イシューID
- `noteable_iid` - 関連イシューIID
- `noteable_type` - `Issue`
- `resolvable` - 解決可能かどうか
- `resolved` - 解決済みかどうか

### ページネーション

レスポンスヘッダに以下が含まれる：
- `X-Total` - 全件数
- `X-Total-Pages` - 全ページ数
- `X-Page` - 現在のページ番号
- `X-Per-Page` - 1ページあたりの件数
- `X-Next-Page` - 次のページ番号（最終ページの場合は空）

全コメントを取得するには、`X-Next-Page` が空になるまでページを繰り返す。
または `glab_api` の `--paginate` フラグで自動ページネーションを使用する：

```
glab_api args: ["projects/<encoded_project>/issues/<iid>/notes"]
  flags:
    method: "GET"
    paginate: true
    raw_field:
      - "per_page=100"
      - "sort=asc"
      - "order_by=created_at"
```

## 関連MRの取得

**エンドポイント:** `GET /projects/:id/issues/:iid/related_merge_requests`

```
glab_api args: ["projects/<encoded_project>/issues/<iid>/related_merge_requests"]
  flags:
    method: "GET"
```

イシューに関連付けられたMR一覧を取得する。各MRには `iid`, `title`, `state`, `web_url` が含まれる。

## ラベル変更履歴の取得

**エンドポイント:** `GET /projects/:id/issues/:iid/resource_label_events`

```
glab_api args: ["projects/<encoded_project>/issues/<iid>/resource_label_events"]
  flags:
    method: "GET"
    raw_field:
      - "per_page=100"
```

ラベルの追加・削除イベントの履歴を取得する。各イベントには `label.name`, `action`（`add`/`remove`）, `created_at` が含まれる。

## エラーハンドリング

- **404 Not Found**: プロジェクトパスのURLエンコードとイシューIIDが正しいか確認する。
- **403 Forbidden**: 認証されたユーザーがこのイシューにアクセスする権限を持っていない可能性がある。
