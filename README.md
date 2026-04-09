# codex-plugin-glab

## 使い方

### 1. Marketplace にプラグインを追加する

`~/.agents/plugins/marketplace.json` の `"plugins"` セクションに以下の内容を記載してください。

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

完全な `~/.agents/plugins/marketplace.json` のサンプル:

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

### 2. .codex ディレクトリにプラグインを配置する

```bash
mkdir -p ~/.codex/plugins
cp -R path/to/codex-plugin-glab/plugins/gitlab ~/.codex/plugins/gitlab
```

## 開発者向け

`glab mcp serve` で公開されるツールの一覧は `references/glab/tools-list.json` に配置されている
