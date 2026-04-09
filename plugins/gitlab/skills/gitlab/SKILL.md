---
name: gitlab
description: Triage and orient GitLab repository, merge request, and issue work through the connected `glab-mcp`. Use when the user asks for general GitLab help, wants MR or issue summaries, or needs repository context before choosing a more specific GitLab workflow.
---

# GitLab

## Overview

Use this skill as the umbrella entrypoint for general GitLab work in this plugin. It should decide whether the task stays in repo and MR triage or should be handed off to a more specific review, CI, or publish workflow.

This plugin is intentionally hybrid:

- Prefer the `glab-mcp` from this plugin for repository, issue, merge request, comment, label, reaction, and MR creation workflows.
- Use local `git` and `glab` only when the connector does not cover the job well, especially for current-branch MR discovery, branch creation, commit and push, `glab auth status`, and GitLab Actions log inspection.
- Keep connector state and local checkout context aligned. If the request is about the current branch, resolve the local repo and branch before acting.

Once the intent is clear, route to the specialist skill immediately and do not keep broad GitLab triage in scope longer than needed.

## Connector-First Responsibilities

Handle these directly in this skill when the request does not need a narrower specialist workflow:

- xxx

Prefer the `glab-mcp` from this plugin for those flows because it provides structured MR, issue, and review-adjacent data without depending on a local checkout. If the repository is not already identifiable from the user request or local git context, ask for the repo instead of pretending there is a repo-search flow that may not exist.

## Routing Rules

1. Resolve the operating context first:
   - If the user provides a repository, MR number, issue number, or URL, use that.
   - If the request is about "this branch" or "the current MR", resolve local git context and use `glab` only as needed to discover the branch MR.
   - If the repository is still ambiguous after local inspection, ask for the repo identifier.
2. Classify the request before taking action:
   - xxx
3. Route to the specialist skill as soon as the category is clear:
   - xxx
4. Keep the hybrid model consistent after routing:
   - connector first for MR and issue data
   - local `git` and `glab` only for the specific gaps the connector does not cover

## Default Workflow

1. Resolve repository and item scope.
2. Gather structured MR or issue context through the `glab-mcp` from this plugin.
3. Decide whether the task stays in connector-backed triage or needs a specialist skill.
4. Route immediately when the work becomes review follow-up, CI debugging, or publish workflow.
5. End with a clear summary of what was inspected, what changed, and what remains.

## Output Expectations

- For triage requests, return a concise summary of the repository, MR, or issue state and the next likely action.
- For mixed requests, tell the user which specialist path you are taking and why.
- For connector-backed write actions, restate the exact MR, issue, label, or reaction target before applying the change.
- Never imply that GitLab CI/CD logs are available through the connector alone. That remains a `glab` workflow.

## Examples

- "Use GitLab to summarize the open MRs in this repo and tell me what needs attention."
- "Help with this MR."
- "Review the latest comments on MR 482 and tell me what is actionable."
- "Debug the failing checks on this branch."
- "Commit these changes, push them, and open a draft MR."
