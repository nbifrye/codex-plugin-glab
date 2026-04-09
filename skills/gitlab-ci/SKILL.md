---
name: gitlab-ci
description: GitLab CI/CD pipeline workflows using glab MCP tools. Use when working with pipelines, jobs, or CI/CD status -- viewing pipeline results, checking job logs, retrying failed jobs, or debugging CI failures on GitLab.
---

# GitLab CI/CD Pipelines

Use the glab MCP server tools for all CI/CD operations.

## View pipelines

- List recent pipelines for the current or specified project
- View pipeline status (running, passed, failed, canceled)
- Filter pipelines by branch, status, or ref

## Inspect jobs

- List jobs within a pipeline
- View individual job status and duration
- Read job logs to diagnose failures
- Identify which stage and job failed

## Retry and cancel

- Retry a single failed job
- Retry all failed jobs in a pipeline
- Cancel a running pipeline

## Debug failures

When a pipeline fails:
1. List the pipeline's jobs to identify which failed
2. Read the failed job's log output
3. Look for error messages, test failures, or timeout issues
4. Suggest fixes based on the log output

## Free-tier notes

- Free tier includes 400 CI/CD minutes per month for shared runners
- Self-hosted runners have no minute limits
- Protected variables and environments are available on Free
- Multi-project pipelines are a Premium feature
- All other CI/CD operations work on Free tier without limitations
