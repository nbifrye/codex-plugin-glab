# GitLab CI/CD API リファレンス

## 概要

GitLab CI/CD APIは、パイプラインとジョブの詳細データを取得するためのAPIである。`glab_ci_*` ツールでカバーしきれない操作（MR関連パイプラインの取得、パイプライン変数の設定等）に `glab_api` を使用する。

## パイプライン一覧の取得

**エンドポイント:** `GET /projects/:id/pipelines`

```
glab_api args: ["projects/<encoded_project>/pipelines"]
  flags:
    method: "GET"
    raw_field:
      - "per_page=20"
      - "ref=<branch_name>"
      - "status=<status>"
```

### パラメータ

- `ref` - ブランチ名またはタグ名でフィルタ
- `status` - パイプライン状態でフィルタ（`running`, `pending`, `success`, `failed`, `canceled`, `skipped`, `manual`）
- `per_page` - 1ページあたりの件数（最大100）
- `order_by` - ソートキー（`id`, `status`, `ref`, `updated_at`, `user_id`）
- `sort` - ソート順（`asc`, `desc`）

## パイプライン詳細の取得

**エンドポイント:** `GET /projects/:id/pipelines/:pipeline_id`

```
glab_api args: ["projects/<encoded_project>/pipelines/<pipeline_id>"]
  flags:
    method: "GET"
```

### レスポンス構造

- `id` - パイプラインID
- `iid` - プロジェクト内パイプラインIID
- `status` - 状態
- `ref` - ブランチ名
- `sha` - コミットSHA
- `created_at`, `updated_at`, `started_at`, `finished_at` - タイムスタンプ
- `duration` - 実行時間（秒）
- `web_url` - Web URL

## パイプラインのジョブ一覧

**エンドポイント:** `GET /projects/:id/pipelines/:pipeline_id/jobs`

```
glab_api args: ["projects/<encoded_project>/pipelines/<pipeline_id>/jobs"]
  flags:
    method: "GET"
    raw_field:
      - "per_page=100"
```

### レスポンス構造（各ジョブ）

- `id` - ジョブID
- `name` - ジョブ名
- `stage` - ステージ名
- `status` - 状態（`created`, `pending`, `running`, `failed`, `success`, `canceled`, `skipped`, `manual`）
- `duration` - 実行時間（秒）
- `web_url` - Web URL
- `failure_reason` - 失敗理由（失敗ジョブのみ）
- `artifacts` - アーティファクト情報
- `runner` - 実行ランナー情報

## MR関連パイプラインの取得

**エンドポイント:** `GET /projects/:id/merge_requests/:iid/pipelines`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/pipelines"]
  flags:
    method: "GET"
```

MRに関連付けられたパイプライン一覧を取得する。

## ジョブログの取得

### glab CLIでの取得

```
glab_ci_trace <job_id>
```

### APIでの取得

**エンドポイント:** `GET /projects/:id/jobs/:job_id/trace`

```
glab_api args: ["projects/<encoded_project>/jobs/<job_id>/trace"]
  flags:
    method: "GET"
```

**注意:** ジョブログは非常に大きくなる場合がある。`glab_ci_trace` には `limit` パラメータがあり、取得するバイト数を制限できる。全ログが不要な場合は適切な制限を設定する。

## パイプライン変数の指定

`glab_ci_run` で手動パイプラインを実行する際、変数を指定する場合：

```
glab_ci_run
  flags:
    variables: ["KEY1:value1", "KEY2:value2"]
```

APIでの変数指定：

```
glab_api args: ["projects/<encoded_project>/pipeline"]
  flags:
    method: "POST"
    raw_field:
      - "ref=<branch_name>"
      - "variables[0][key]=KEY1"
      - "variables[0][value]=value1"
      - "variables[1][key]=KEY2"
      - "variables[1][value]=value2"
```

## パイプラインのリトライ

**エンドポイント:** `POST /projects/:id/pipelines/:pipeline_id/retry`

```
glab_api args: ["projects/<encoded_project>/pipelines/<pipeline_id>/retry"]
  flags:
    method: "POST"
```

パイプライン内の失敗ジョブをすべてリトライする。

## エラーハンドリング

- **404 Not Found**: パイプラインIDまたはジョブIDが正しいか、プロジェクトパスのURLエンコードが正しいか確認する。
- **403 Forbidden**: パイプラインの実行やキャンセルにはDeveloper以上の権限が必要。
- **400 Bad Request**: パイプライン変数の形式が正しくない可能性がある。
