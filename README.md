# codex-plugin-glab

GitLab リポジトリ・マージリクエスト・イシューの管理を支援する **Codex 専用プラグイン** です。

`glab mcp serve` を MCP サーバーとして利用し、137 以上の GitLab CLI ツールを Codex に統合します。MR のトリアージ・作成・レビュー・コメント対応、イシューの検索・取得・開発着手、CI/CD パイプラインの監視・デバッグまでを、**8 つの専門スキル** でカバーします。

## アーキテクチャ

本プラグインはビルド不要の設定ベースプラグインで、ハイブリッド構成を採用しています。

- **MCP サーバー** (`glab mcp serve`): リポジトリ、MR、イシュー、コメント、ラベルなどの構造化データへのアクセスを提供
- **ローカル git / glab CLI**: ブランチ作成、コミット・プッシュ、現在のブランチの MR 検出、`glab auth status` など、MCP サーバーがカバーしない操作に使用

エントリーポイントとなる `$gitlab` スキルがリクエストを分類し、適切な専門スキルへ自動的にルーティングします。

## ディレクトリ構成

```
codex-plugin-glab/
├── plugins/gitlab/
│   ├── .codex-plugin/
│   │   └── plugin.json                      # プラグインマニフェスト
│   ├── .mcp.json                            # MCP サーバー設定 (glab mcp serve)
│   ├── .app.json                            # アプリ設定 (現状未使用)
│   ├── hooks.json                           # フック設定 (現状未使用)
│   ├── scripts/                             # 拡張用 (現状未使用)
│   ├── assets/
│   │   └── gitlab-logo-500-rgb.png          # GitLab ロゴ
│   └── skills/                              # 各スキルは SKILL.md + agents/openai.yaml を持つ
│       ├── gitlab/                          # トリアージ・ルーティング (SKILL.md のみ)
│       ├── gitlab-mr-review/                # MR コードレビュー
│       │   └── references/gitlab-discussions-api.md
│       ├── gitlab-mr-address-comments/      # 未解決レビューコメント対応
│       │   └── references/gitlab-discussions-api.md
│       ├── gitlab-mr-create/                # MR 作成
│       ├── gitlab-ci/                       # CI/CD 監視・デバッグ
│       │   └── references/gitlab-ci-api.md
│       ├── gitlab-issue-develop/            # イシュー起点の開発着手
│       ├── gitlab-issue-fetch/              # イシュー本文・全コメント取得
│       │   └── references/gitlab-issue-notes-api.md
│       └── gitlab-issue-search/             # 関連イシュー検索
│           └── references/gitlab-search-api.md
└── references/glab/
    └── tools-list.json                      # glab CLI ツール一覧
```

## 前提条件

1. **Codex** がインストール・起動されていること
2. **glab CLI** がインストールされ、GitLab に認証済みであること
   - インストールと設定については公式ページを参照してください: https://gitlab.com/gitlab-org/cli
3. **Git** がインストールされていること

## インストール

### 1. プラグインファイルの配置

```bash
mkdir -p ~/.codex/plugins
cp -R path/to/codex-plugin-glab/plugins/gitlab ~/.codex/plugins/gitlab
```

### 2. Marketplace への登録

`~/.agents/plugins/marketplace.json` の `"plugins"` セクションに以下を追加してください。

```json
{
  "name": "gitlab",
  "source": {
    "source": "local",
    "path": "./.codex/plugins/gitlab"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

<details>
<summary>marketplace.json の完全な例</summary>

```json
{
  "name": "local-plugins",
  "interface": {
    "displayName": "Local Plugins"
  },
  "plugins": [
    {
      "name": "gitlab",
      "source": {
        "source": "local",
        "path": "./.codex/plugins/gitlab"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
    }
  ]
}
```

</details>

## スキル一覧

| スキル | 用途 | 主な操作 |
|--------|------|----------|
| `$gitlab` | 汎用トリアージ・ルーティング入口 | MR/イシューの一覧・閲覧、ラベル/担当者管理、専門スキルへの自動ルーティング |
| `$gitlab-mr-review` | MR コードレビュー | diff 分析（バグ・セキュリティ・パフォーマンス・設計）、行単位インラインコメント、承認/変更依頼 |
| `$gitlab-mr-address-comments` | 未解決レビューコメント対応 | ディスカッション取得、修正実装、返信投稿、解決、コミット・プッシュ |
| `$gitlab-mr-create` | 現在のブランチから MR 作成 | タイトル/説明生成、イシューリンク、ラベル・レビュアー・ドラフト設定 |
| `$gitlab-ci` | CI/CD パイプライン監視・デバッグ | ステータス確認、ジョブログ解析、`.gitlab-ci.yml` lint、手動実行、ジョブのリトライ |
| `$gitlab-issue-develop` | イシュー起点の開発着手 | イシュー分析、フィーチャーブランチ作成、実装、イシュー紐付けコミット |
| `$gitlab-issue-fetch` | イシュー本文・全コメント取得 | ページネーション対応、関連 MR/イシュー抽出、時系列整理 |
| `$gitlab-issue-search` | 関連イシュー探索 | テキスト/ラベル検索、GitLab Search API、関連度評価 |

### スキル連携フロー

`$gitlab` がエントリーポイントとして機能し、ユーザーの意図に応じて専門スキルへ自動的にルーティングします。典型的な連携パターンは次のとおりです。

```
$gitlab-issue-develop → $gitlab-mr-create → $gitlab-ci → $gitlab-mr-review
$gitlab-issue-search  → $gitlab-issue-fetch
```

## 使い方

### `$gitlab`

```
このリポジトリのオープン MR を要約して、対応が必要なものを教えて。
```

```
このブランチの失敗したチェックをデバッグして。
```

### `$gitlab-mr-review`

```
$gitlab-mr-review を使用して、MR !42 をレビューして。
```

```
現在のブランチの MR をレビューして、インラインコメントを投稿して。
```

### `$gitlab-mr-address-comments`

```
$gitlab-mr-address-comments を使用して、MR !42 の未解決コメントをすべて対応して。
```

```
未解決のレビューコメントを修正して。
```

### `$gitlab-mr-create`

```
現在のブランチからドラフト MR を作成して。
```

```
このブランチからイシュー #42 にリンクした MR を作成して。
```

### `$gitlab-ci`

```
現在のブランチの CI/CD パイプラインのステータスを確認して。
```

```
MR !42 のパイプライン失敗を診断して、失敗ジョブをリトライして。
```

### `$gitlab-issue-develop`

```
イシュー #42 に基づいて開発を始めて。
```

### `$gitlab-issue-fetch`

```
イシュー #15 の全コメントを見せて。
```

### `$gitlab-issue-search`

```
このエラーメッセージに関連するイシューを探して。
```

## MCP ツール

`glab mcp serve` は以下のカテゴリの GitLab CLI ツールを MCP サーバー経由で公開します。

| カテゴリ | 主なツール例 |
|----------|-------------|
| マージリクエスト | `mr_view`, `mr_diff`, `mr_create`, `mr_merge`, `mr_approve`, `mr_list` など |
| イシュー | `issue_list`, `issue_view`, `issue_create`, `issue_close` など |
| CI/CD | `ci_status`, `ci_list`, `ci_trace`, `ci_lint` など |
| リポジトリ | `repo_clone`, `repo_fork`, `repo_view`, `repo_archive` など |
| その他 | ラベル、マイルストーン、リリース、ランナー、変数、スケジュール管理など |

全ツールの一覧は `references/glab/tools-list.json` を参照してください。

## 開発者向け

### ツール一覧の更新

`references/glab/tools-list.json` は `glab mcp serve` が公開するツールの一覧です。glab CLI の更新に伴いツールが追加・変更された場合は、このファイルを更新してください。

### スキルの追加・修正

各スキルは以下の構成に従います。

```
skills/<skill-name>/
├── SKILL.md              # スキル定義（frontmatter + ワークフロー）
├── agents/
│   └── openai.yaml       # エージェント設定（任意）
└── references/           # スキルが参照するドキュメント（任意）
```

- `SKILL.md` の frontmatter (`name`, `description`) がスキルの識別と呼び出し条件を定義します
- `references/` ディレクトリに API リファレンスなどの補足資料を配置できます

> `hooks.json` / `.app.json` / `scripts/` は現在未使用です。将来的にフック機能やアプリ連携を追加する際に利用します。

## ライセンス

MIT ライセンスの下で公開されています。詳細は `plugins/gitlab/.codex-plugin/plugin.json` の `license` フィールドを参照してください。
