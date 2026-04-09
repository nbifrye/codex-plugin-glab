# codex-plugin-glab

GitLab リポジトリ・マージリクエスト・イシューの管理を支援する Claude Code (Codex) プラグインです。

`glab mcp serve` を MCP サーバーとして利用し、137 以上の GitLab CLI ツールを Claude Code に統合します。3 つの専門スキルにより、MR/イシューのトリアージからコードレビュー、レビューコメントへの対応まで、GitLab ワークフロー全体をカバーします。

## 特徴

### GitLab トリアージ (`$gitlab`)

汎用的な GitLab 操作の入口となるスキルです。

- MR・イシューの一覧表示、閲覧、作成、更新、クローズ、再オープン
- ラベル、マイルストーン、担当者、レビュアーの管理
- MR の承認ステータス確認
- CI/CD パイプラインのステータス確認
- 必要に応じて専門スキルへの自動ルーティング

### MR コードレビュー (`$gitlab-mr-review`)

MR の変更内容をレビューし、フィードバックを投稿します。

- diff の読み取りと分析（バグ、セキュリティ、パフォーマンス、設計）
- 特定の行への位置ベースのインラインコメント投稿
- レビューサマリーコメントの投稿
- MR の承認または変更依頼

### レビューコメント対応 (`$gitlab-mr-address-comments`)

未解決のレビューコメントに対応し、修正を実装します。

- 未解決ディスカッションの一覧取得と解析
- レビュアーのフィードバックに基づくコード修正の実装
- 変更内容を説明する返信の投稿
- ディスカッションの解決
- 変更のコミットとプッシュ

## アーキテクチャ

本プラグインはビルド不要の設定ベースプラグインで、ハイブリッド構成を採用しています。

- **MCP サーバー** (`glab mcp serve`): リポジトリ、MR、イシュー、コメント、ラベルなどの構造化データへのアクセスを提供
- **ローカル git / glab CLI**: ブランチ作成、コミット・プッシュ、現在のブランチの MR 検出など、MCP サーバーがカバーしない操作に使用

```
codex-plugin-glab/
├── plugins/gitlab/
│   ├── .codex-plugin/
│   │   └── plugin.json                  # プラグインマニフェスト
│   ├── .mcp.json                        # MCP サーバー設定
│   ├── .app.json                        # アプリ設定
│   ├── hooks.json                       # フック設定
│   ├── assets/
│   │   └── gitlab-logo-500-rgb.png      # GitLab ロゴ
│   └── skills/
│       ├── gitlab/
│       │   └── SKILL.md                 # トリアージスキル
│       ├── gitlab-mr-review/
│       │   ├── SKILL.md                 # MR レビュースキル
│       │   ├── agents/openai.yaml
│       │   └── references/
│       │       └── gitlab-discussions-api.md
│       └── gitlab-mr-address-comments/
│           ├── SKILL.md                 # コメント対応スキル
│           ├── agents/openai.yaml
│           └── references/
│               └── gitlab-discussions-api.md
└── references/glab/
    └── tools-list.json                  # glab CLI ツール一覧
```

## 前提条件

1. **Claude Code (Codex)** がインストール・起動されていること
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

## 使い方

### GitLab トリアージ

```
このリポジトリのオープン MR を要約して。
```

```
イシュー #123 にラベル「bug」を追加して。
```

```
これらの変更をコミットしてプッシュし、ドラフト MR を作成して。
```

### MR コードレビュー

```
$gitlab-mr-review を使用して、MR !42 をレビューして。
```

```
現在のブランチの MR をレビューして、インラインコメントを投稿して。
```

### レビューコメント対応

```
$gitlab-mr-address-comments を使用して、MR !42 の未解決コメントをすべて対応して。
```

```
未解決のレビューコメントを修正して。
```

## スキル一覧

| スキル | 説明 | トリガー例 |
|--------|------|------------|
| `$gitlab` | 汎用トリアージ・ルーティング | MR/イシューの一覧、作成、管理全般 |
| `$gitlab-mr-review` | コードレビュー・インラインコメント | MR のレビュー依頼、コード品質チェック |
| `$gitlab-mr-address-comments` | レビューコメントへの対応・修正 | 未解決ディスカッションの修正依頼 |

`$gitlab` スキルがエントリーポイントとして機能し、ユーザーの意図に応じて専門スキルに自動的にルーティングします。

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
│   └── openai.yaml       # エージェント設定
└── references/           # スキルが参照するドキュメント
```

- `SKILL.md` の frontmatter (`name`, `description`) がスキルの識別と呼び出し条件を定義します
- `references/` ディレクトリに API リファレンスなどの補足資料を配置できます

### 既知の TODO

- ライセンスの確定 (`plugin.json` の `license` フィールド)
- ホームページ URL の設定
- カテゴリ・ケイパビリティの確定
- `hooks.json` / `.app.json` は現在未使用（拡張ポイント）

## ライセンス

未確定。`plugins/gitlab/.codex-plugin/plugin.json` の `license` フィールドを参照してください。
