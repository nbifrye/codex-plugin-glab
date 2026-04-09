# codex-plugin-glab

## 使い方

### 1. Marketplace にプラグインを追加する

`~/.agents/plugins/marketplace.json` の `"plugins"` セクションに以下の内容を記載してください。

```json
{
  "name": "gitlab",
  "source": {
    "source": "local",
    "path": "./plugins/gitlab"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Productivity"
}
```

### 2. .codex ディレクトリにプラグインを配置する

```bash
mkdir -p ~/.codex/plugins
cp -R path/to/codex-plugin-glab/plugins/gitlab ~/.codex/plugins/gitlab
```
