---
name: gitlab-mr-address-comments
description: >-
  List unresolved review discussions on a GitLab merge request, implement code
  fixes for each, reply to the discussion explaining the change, and resolve it.
  Use when the user asks to address, fix, or respond to MR review comments,
  unresolved discussions, or review feedback.
---

# GitLab MR Address Comments

Fetch unresolved MR review discussions, implement code fixes, reply explaining each change, and resolve the discussions.

## Workflow

1. **Resolve MR context**
   - If the user provides an MR number, use it directly.
   - If working on a branch, run `glab_mr_for` to discover the MR for the current branch.
   - Determine the project path from local git remote or user input.

2. **Fetch unresolved discussions**
   - Run `glab_mr_view <IID> --comments --unresolved` for a quick human-readable overview.
   - For structured data (discussion IDs, positions, note IDs), call `glab_api` GET `projects/<encoded_project>/merge_requests/<iid>/discussions`.
   - Read `references/gitlab-discussions-api.md` for the response structure.
   - Filter to discussions where at least one note has `resolvable: true` and `resolved: false`.

3. **Parse each unresolved discussion**
   - Extract from each discussion:
     - `discussion.id` - needed for replies and resolution
     - `notes[0].body` - the reviewer's comment text
     - `notes[0].position.new_path` - file path (if inline comment)
     - `notes[0].position.new_line` - line number (if inline comment)
   - For general comments (no `position`), interpret the comment to identify which code it refers to.
   - Group related discussions that affect the same file or area to plan coherent fixes.

4. **Present findings to user**
   - List all unresolved discussions with: file, line, reviewer comment summary.
   - Confirm the plan of action before making changes, unless the user asked to fix all.

5. **Checkout the MR branch**
   - If not already on the MR source branch, run `glab_mr_checkout <IID>` or `git checkout <branch>`.
   - Pull the latest changes.

6. **Implement fixes**
   - For each discussion (or group), apply the code change that addresses the reviewer's concern.
   - Read the surrounding code for full context before editing.
   - Make minimal, focused changes that directly address the feedback.

7. **Reply to each discussion**
   - After implementing the fix, reply to the discussion via `glab_api`:
     ```
     args: ["projects/<encoded_project>/merge_requests/<iid>/discussions/<discussion_id>/notes"]
     flags:
       method: "POST"
       field:
         - "body=<explanation of the fix>"
     ```
   - Keep replies concise: state what was changed and why.

8. **Resolve each discussion**
   - After replying, resolve the discussion via `glab_api`:
     ```
     args: ["projects/<encoded_project>/merge_requests/<iid>/discussions/<discussion_id>"]
     flags:
       method: "PUT"
       field:
         - "resolved=true"
     ```

9. **Commit and push**
   - Commit all changes with a descriptive message (e.g., "Address MR review comments for !<IID>").
   - Push to the MR source branch.

## Discussion Parsing Guidance

- **Inline comments** have a `position` object with `new_path` and `new_line` - use these to locate the exact code.
- **General comments** lack `position` - read the comment body carefully to identify which code is being discussed. The reviewer may reference file names, function names, or line numbers in the text.
- **Threaded discussions** may have multiple notes. Read all notes in the thread to understand the full conversation and the latest state of the feedback.
- **Already-resolved discussions** (all notes have `resolved: true`) should be skipped.

## Output

For each discussion addressed, report:
1. The original reviewer comment (abbreviated)
2. The file and line affected
3. The fix applied
4. The reply posted

End with: total discussions addressed, commit hash, and push status.
