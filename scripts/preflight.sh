#!/usr/bin/env bash
# preflight.sh - Verify glab CLI is installed and authenticated
set -euo pipefail

errors=0

# Check glab is installed
if ! command -v glab &>/dev/null; then
  echo "FAIL: glab CLI is not installed."
  echo "      Install from https://gitlab.com/gitlab-org/cli or your package manager."
  errors=$((errors + 1))
else
  echo "OK:   glab CLI found at $(command -v glab)"

  # Check authentication
  if glab auth status &>/dev/null 2>&1; then
    echo "OK:   glab authentication is configured."
  else
    echo "FAIL: glab is not authenticated."
    echo "      Run: glab auth login"
    echo "      For self-hosted: glab auth login --hostname gitlab.example.com"
    errors=$((errors + 1))
  fi
fi

if [ "$errors" -eq 0 ]; then
  echo ""
  echo "All checks passed. The plugin is ready to use."
else
  echo ""
  echo "$errors check(s) failed. Fix the issues above before using the plugin."
  exit 1
fi
