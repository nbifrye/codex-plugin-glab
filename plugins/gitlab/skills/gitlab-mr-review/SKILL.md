---
name: gitlab-mr-review
description: >-
  GitLabマージリクエストをレビューする：diffを読み取り、コード品質を分析し、
  特定の行にインラインdiffコメントを投稿し、レビューサマリーを送信する。
  ユーザーがMRのレビュー、コードレビューフィードバックの提供、
  マージリクエストへのレビューコメント投稿を求めた場合に使用する。
---

# GitLab MR レビュー

MRのコード変更をレビューし、特定の行へのインラインdiffコメント（位置ベース）とサマリーコメントとしてフィードバックを投稿する。

## ワークフロー

1. **MRコンテキストの解決**
   - ユーザーがMR番号を提供した場合、それを直接使用する。
   - ブランチで作業中の場合、現在のブランチのMRを検出する：
     - `glab_mr_list` の `source_branch` フラグに現在のブランチ名を指定して、`state=opened` でフィルタする。
     - または `glab_mr_view`（`args` を空にする）でローカルの現在ブランチに紐づくMRを解決する。
   - ローカルのgitリモートまたはユーザー入力からプロジェクトパスを特定する。

2. **MRメタデータの取得**
   - `glab_mr_view <IID> --output json` を実行して以下を取得する：
     - タイトル、説明、作成者、ラベル、ソース/ターゲットブランチ
     - `diff_refs` オブジェクト: `base_sha`, `head_sha`, `start_sha`（インラインコメントに必要）
   - `diff_refs` が出力に含まれない場合、`glab_api` GET `projects/:encoded_project/merge_requests/:iid` で取得し、`diff_refs` を抽出する。

3. **diffの取得と分析**
   - `glab_mr_diff <IID>` を実行してフルdiffを取得する。
   - 大きなdiffの場合、変更行周辺の完全なコンテキストを得るためにローカルのソースファイルを読み取る。
   - 分析対象: バグ、ロジックエラー、セキュリティ脆弱性、パフォーマンス問題、エラーハンドリングの不備、設計上の懸念。
   - 可読性に大きく影響しない限り、些細なスタイルの指摘はスキップする。

4. **インラインdiffコメントの投稿**
   - 特定の行に紐づく実質的な指摘事項ごとに、位置ベースのディスカッションを投稿する。
   - 投稿前に `references/gitlab-discussions-api.md` で正確なAPI呼び出し手順を確認すること。
   - 各コメントには: 問題の明確な記述、それが重要な理由の説明、可能であれば修正案を含める。

5. **サマリーコメントの投稿**
   - インラインコメント投稿後、`glab_mr_note <IID> --message "<summary>"` でサマリーを投稿する。
   - 含める内容: 全体評価、重要度別の指摘件数、MRがマージ可能かどうか。

6. **承認またはレビュー依頼**
   - ブロッキングイシューが見つからず、ユーザーが要求した場合、`glab_mr_approve <IID>` で承認する。
   - そうでなければ、MRを未承認のままとし、変更が必要な点を記述する。

## インラインdiffコメントの手順

これは特定の行にコメントを投稿するための重要な手順である。正確に従うこと。

1. ステップ2で取得したMRメタデータからSHA値を抽出する：
   - `base_sha` - マージベースコミット
   - `head_sha` - ソースブランチのヘッドコミット
   - `start_sha` - diffの開始コミット

2. プロジェクトパスをURLエンコードする（例: `group/project` は `group%2Fproject` になる）。

3. 各指摘事項について `glab_api` を呼び出す。**Go テンプレートレンダリングによるSHA値の破損を防ぐため、`raw_field`（`field` ではなく）を使用する。**

   **新規（追加）行へのコメント：**
   ```
   args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
   flags:
     method: "POST"
     raw_field:
       - "body=<comment text>"
       - "position[base_sha]=<base_sha>"
       - "position[head_sha]=<head_sha>"
       - "position[start_sha]=<start_sha>"
       - "position[position_type]=text"
       - "position[old_path]=<file_path>"
       - "position[new_path]=<file_path>"
       - "position[new_line]=<line_number>"
   ```

   **削除行へのコメント：**
   ```
   args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
   flags:
     method: "POST"
     raw_field:
       - "body=<comment text>"
       - "position[base_sha]=<base_sha>"
       - "position[head_sha]=<head_sha>"
       - "position[start_sha]=<start_sha>"
       - "position[position_type]=text"
       - "position[old_path]=<file_path>"
       - "position[new_path]=<file_path>"
       - "position[old_line]=<line_number>"
   ```

   **変更行へのコメント（旧行と新行の両方が存在）：**
   `old_line` と `new_line` の両方、および `old_path` と `new_path` を含める。

4. 位置ベースのコメントが失敗した場合（例: 行がdiff内に存在しない）、`glab_mr_note` を使用してメッセージ本文にファイルと行番号を記載した一般コメントにフォールバックする。

## レビュー品質ガイドライン

- 優先順位: バグ > セキュリティ > 正確性 > パフォーマンス > 保守性
- 具体的に: 正確な変数名、関数呼び出し、条件を参照する
- 修正案を提示: 改善内容が明確な場合はコードスニペットを含める
- 関連する指摘事項は隣接行に影響する場合、単一のコメントにまとめる
- 避けるべきこと: スタイルのみの指摘、個人的な好み、diffが既に示している内容の繰り返し

## 出力

投稿した各コメントについて、ファイルパス、行番号、指摘事項の要約を報告する。レビューサマリーと承認ステータスで締めくくる。
