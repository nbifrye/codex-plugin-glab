# GitLab Discussions API リファレンス

## 概要

GitLab Discussions APIは、マージリクエストのdiffに対する位置ベース（インライン）コメントの作成を可能にする。`glab_mr_note` ツールは一般コメントのみサポートするため、インラインdiffコメントには `glab_api` を使用する。

## 前提条件

### diff_refs の取得

位置ベースコメントに必要なSHA値を取得する：

```
glab_mr_view <IID> --output json
```

レスポンスから以下を抽出する：
- `diff_refs.base_sha` - マージベースコミット
- `diff_refs.head_sha` - ソースブランチのヘッド
- `diff_refs.start_sha` - diff範囲の開始点

`glab_mr_view` で `diff_refs` が取得できない場合、以下を使用する：

```
glab_api GET projects/<encoded_project>/merge_requests/<iid>
```

### プロジェクトパスのURLエンコード

プロジェクトパス内の `/` を `%2F` に置換する：
- `my-group/my-project` → `my-group%2Fproject`
- `group/subgroup/project` → `group%2Fsubgroup%2Fproject`

## インラインディスカッションの作成（位置ベースコメント）

**エンドポイント:** `POST /projects/:id/merge_requests/:iid/discussions`

### 新規（追加）行へのコメント

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
  flags:
    method: "POST"
    raw_field:
      - "body=Comment text here"
      - "position[base_sha]=abc123..."
      - "position[head_sha]=def456..."
      - "position[start_sha]=ghi789..."
      - "position[position_type]=text"
      - "position[new_path]=src/main.py"
      - "position[new_line]=42"
```

### 削除行へのコメント

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
  flags:
    method: "POST"
    raw_field:
      - "body=Comment text here"
      - "position[base_sha]=abc123..."
      - "position[head_sha]=def456..."
      - "position[start_sha]=ghi789..."
      - "position[position_type]=text"
      - "position[old_path]=src/main.py"
      - "position[old_line]=10"
```

### 変更行へのコメント

旧位置と新位置の両方を含める：

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
  flags:
    method: "POST"
    raw_field:
      - "body=Comment text here"
      - "position[base_sha]=abc123..."
      - "position[head_sha]=def456..."
      - "position[start_sha]=ghi789..."
      - "position[position_type]=text"
      - "position[old_path]=src/main.py"
      - "position[old_line]=10"
      - "position[new_path]=src/main.py"
      - "position[new_line]=12"
```

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

- **400 Bad Request（位置エラー）**: 指定された行がdiffの一部ではない。diff出力内にその行番号が存在することを確認する。`glab_mr_note` による一般コメントにフォールバックする。
- **404 Not Found**: プロジェクトパスが正しくURLエンコードされているか、MR IIDが正しいか確認する。
- **403 Forbidden**: 認証されたユーザーがこのMRにコメントする権限を持っていない可能性がある。
