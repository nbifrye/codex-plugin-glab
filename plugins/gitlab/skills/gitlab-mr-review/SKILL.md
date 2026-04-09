---
name: gitlab-mr-review
description: >-
  Review a GitLab merge request: read the diff, analyze code quality, post
  inline diff comments on specific lines, and submit a review summary.
  Use when the user asks to review an MR, provide code review feedback,
  or post review comments on a merge request.
---

# GitLab MR Review

Review MR code changes and post feedback as inline diff comments (position-based) on specific lines and a summary comment.

## Workflow

1. **Resolve MR context**
   - If the user provides an MR number, use it directly.
   - If working on a branch, run `glab_mr_for` to discover the MR for the current branch.
   - Determine the project path from local git remote or user input.

2. **Fetch MR metadata**
   - Run `glab_mr_view <IID> --output json` to get:
     - Title, description, author, labels, source/target branches
     - `diff_refs` object: `base_sha`, `head_sha`, `start_sha` (required for inline comments)
   - If `diff_refs` is not in the output, fetch via `glab_api` GET `projects/:encoded_project/merge_requests/:iid` and extract `diff_refs`.

3. **Fetch and analyze the diff**
   - Run `glab_mr_diff <IID>` to get the full diff.
   - For large diffs, read relevant source files locally for full context around changed lines.
   - Analyze for: bugs, logic errors, security vulnerabilities, performance issues, error handling gaps, and design concerns.
   - Skip trivial style nits unless they affect readability significantly.

4. **Post inline diff comments**
   - For each substantive finding tied to a specific line, post a position-based discussion.
   - Read `references/gitlab-discussions-api.md` for the exact API call procedure before posting.
   - Each comment should: state the issue clearly, explain why it matters, and suggest a fix when possible.

5. **Post summary comment**
   - After posting inline comments, post a summary via `glab_mr_note <IID> --message "<summary>"`.
   - Include: overall assessment, number of issues found by severity, and whether the MR is ready to merge.

6. **Approve or request changes**
   - If no blocking issues found and the user requests it, approve via `glab_mr_approve <IID>`.
   - Otherwise, leave the MR unapproved and state what needs to change.

## Inline Diff Comment Procedure

This is the critical procedure for posting comments on specific lines. Follow exactly.

1. Extract SHA values from the MR metadata obtained in step 2:
   - `base_sha` - the merge base commit
   - `head_sha` - the head commit of the source branch
   - `start_sha` - the start commit of the diff

2. URL-encode the project path (e.g., `group/project` becomes `group%2Fproject`).

3. For each finding, call `glab_api`. **Use `raw_field` (not `field`)** to avoid Go template rendering that corrupts SHA values.

   **Comment on a new/added line:**
   ```
   args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
   flags:
     method: "POST"
     raw_field:
       - "body=<comment text>"
       - "position[base_sha]=<base_sha>"
       - "position[head_sha]=<head_sha>"
       - "position[start_sha]=<start_sha>"
       - "position[position_type]=text"
       - "position[old_path]=<file_path>"
       - "position[new_path]=<file_path>"
       - "position[new_line]=<line_number>"
   ```

   **Comment on a deleted line:**
   ```
   args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
   flags:
     method: "POST"
     raw_field:
       - "body=<comment text>"
       - "position[base_sha]=<base_sha>"
       - "position[head_sha]=<head_sha>"
       - "position[start_sha]=<start_sha>"
       - "position[position_type]=text"
       - "position[old_path]=<file_path>"
       - "position[new_path]=<file_path>"
       - "position[old_line]=<line_number>"
   ```

   **Comment on a modified line (both old and new exist):**
   Include both `old_line` and `new_line` along with `old_path` and `new_path`.

4. If a position-based comment fails (e.g., line not in diff), fall back to a general comment via `glab_mr_note` mentioning the file and line in the message body.

## Review Quality Guidelines

- Prioritize: bugs > security > correctness > performance > maintainability
- Be specific: reference exact variable names, function calls, or conditions
- Suggest fixes: include code snippets when the improvement is clear
- Group related issues in a single comment when they affect adjacent lines
- Avoid: style-only nits, personal preferences, restating what the diff already shows

## Output

Report each comment posted with file path, line number, and issue summary. End with the review summary and approval status.
