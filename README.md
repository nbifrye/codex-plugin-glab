# codex-plugin-glab

GitLab integration plugin for Codex. Provides merge request, issue, and CI/CD pipeline workflows via the [glab CLI](https://gitlab.com/gitlab-org/cli)'s built-in MCP server.

Works with both GitLab SaaS and self-hosted free-tier instances.

## Prerequisites

1. **glab CLI** installed ([installation guide](https://gitlab.com/gitlab-org/cli#installation))
2. **glab authenticated** to your GitLab instance

For GitLab SaaS:

```bash
glab auth login
```

For self-hosted GitLab:

```bash
glab auth login --hostname gitlab.example.com
```

Verify your setup:

```bash
bash scripts/preflight.sh
```

## Installation

### 1. Copy the plugin

```bash
cp -R /path/to/codex-plugin-glab ~/.codex/plugins/codex-plugin-glab
```

### 2. Add the marketplace entry

Add the following to the `"plugins"` array in your `marketplace.json`:

```json
{
  "name": "codex-plugin-glab",
  "source": {
    "source": "local",
    "path": "./plugins/codex-plugin-glab"
  },
  "policy": {
    "installation": "AVAILABLE",
    "authentication": "ON_INSTALL"
  },
  "category": "Developer Tools"
}
```

## Included Skills

| Skill | Description |
|-------|-------------|
| **gitlab-mr** | Create, review, and manage merge requests |
| **gitlab-issues** | Create, triage, and manage issues |
| **gitlab-ci** | View pipelines, debug failures, and manage CI jobs |

## Self-Hosted GitLab (Free Tier)

This plugin is designed to work with self-hosted free-tier GitLab. Some GitLab features require a paid tier:

- **Free**: Issues, merge requests, CI/CD (400 min/month shared runners), issue boards, protected variables
- **Premium required**: Epics, scoped labels, code owners, approval rules, multi-project pipelines

Self-hosted runners have no CI minute limits.

## License

MIT
