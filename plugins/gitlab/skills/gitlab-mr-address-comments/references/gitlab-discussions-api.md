# GitLab Discussions API リファレンス

## 概要

GitLab Discussions APIは、マージリクエストのディスカッションの一覧表示、返信、解決に使用する。これらのエンドポイントの呼び出しには `glab_api` を使用する。

## 前提条件

### プロジェクトパスのURLエンコード

プロジェクトパス内の `/` を `%2F` に置換する：
- `my-group/my-project` → `my-group%2Fmy-project`
- `group/subgroup/project` → `group%2Fsubgroup%2Fproject`

## ディスカッション一覧の取得

**エンドポイント:** `GET /projects/:id/merge_requests/:iid/discussions`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
  flags:
    method: "GET"
```

### レスポンス構造

各ディスカッションには以下が含まれる：
- `id` - ディスカッションID（返信と解決に使用）
- `individual_note` - スタンドアロンのノートの場合はtrue、スレッドディスカッションの場合はfalse
- `notes[]` - ディスカッション内のノート配列：
  - `notes[].id` - ノートID
  - `notes[].body` - コメントテキスト
  - `notes[].author.username` - 作成者
  - `notes[].position` - 位置オブジェクト（インラインコメントの場合）：
    - `position.new_path` - 新バージョンのファイルパス
    - `position.new_line` - 新バージョンの行番号
    - `position.old_path` - 旧バージョンのファイルパス
    - `position.old_line` - 旧バージョンの行番号
  - `notes[].resolvable` - このノートが解決可能かどうか
  - `notes[].resolved` - このノートが解決済みかどうか

### 未解決ディスカッションのフィルタリング

すべてのディスカッション取得後、クライアント側でフィルタリングする：
- `notes[].resolvable == true` かつ `notes[].resolved == false` のディスカッションを保持する
- すべての解決可能ノートが既に解決済みのディスカッションはスキップする

代替手段として、`glab_mr_view <IID> --comments --unresolved` でテキスト形式の簡易概要を取得できる（構造化JSONではない）。

## ディスカッションへの返信

**エンドポイント:** `POST /projects/:id/merge_requests/:iid/discussions/:discussion_id/notes`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions/<discussion_id>/notes"]
  flags:
    method: "POST"
    raw_field:
      - "body=Reply text here"
```

## ディスカッションの解決 / 未解決化

**エンドポイント:** `PUT /projects/:id/merge_requests/:iid/discussions/:discussion_id`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions/<discussion_id>"]
  flags:
    method: "PUT"
    raw_field:
      - "resolved=true"
```

未解決にする場合は `resolved=false` を設定する。

## エラーハンドリング

- **404 Not Found**: プロジェクトパスが正しくURLエンコードされているか、MR IIDが正しいか確認する。
- **403 Forbidden**: 認証されたユーザーがこのMRのディスカッションにコメントまたは解決する権限を持っていない可能性がある。
