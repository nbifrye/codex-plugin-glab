---
name: gitlab-mr
description: GitLab merge request workflows using glab MCP tools. Use when working with merge requests (MRs) -- creating, reviewing, listing, updating, merging, or addressing review comments on GitLab. Triggers on any merge-request-related task for GitLab projects.
---

# GitLab Merge Requests

Use the glab MCP server tools for all merge request operations.

## List and inspect

- List open MRs for the current or specified project
- View MR details: description, reviewers, approvals, CI status
- View MR diffs and file changes
- List comments and discussion threads

## Create

- Create an MR from current branch to target branch (default: main)
- Set title, description, assignees, reviewers, labels, milestone
- Mark as draft with `Draft:` prefix in title when not ready for review

## Update and manage

- Edit title, description, labels, assignees, reviewers
- Add comments and reply to discussion threads
- Resolve discussion threads
- Rebase source branch onto target

## Review

- View diff for each changed file
- Post line-level and general comments
- Approve an MR (if the user has permission)

## Merge

- Merge when pipeline succeeds (preferred default)
- Squash commits on merge when appropriate
- Delete source branch after merge

## Free-tier notes

- Approval rules and required approvals are not available on GitLab Free
- Code owners (CODEOWNERS) are a Premium feature
- Merge request approvals work but are optional on Free tier
- All other MR operations work on Free tier without limitations
