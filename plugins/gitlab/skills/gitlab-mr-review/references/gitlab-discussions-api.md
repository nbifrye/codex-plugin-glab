# GitLab Discussions API Reference

## Overview

The GitLab Discussions API enables creating position-based (inline) comments on merge request diffs. The `glab_mr_note` tool only supports general comments, so use `glab_api` for inline diff comments.

## Prerequisites

### Get diff_refs

Obtain SHA values required for position-based comments:

```
glab_mr_view <IID> --output json
```

Extract from the response:
- `diff_refs.base_sha` - merge base commit
- `diff_refs.head_sha` - head of the source branch
- `diff_refs.start_sha` - start of the diff range

If `diff_refs` is not available via `glab_mr_view`, use:

```
glab_api GET projects/<encoded_project>/merge_requests/<iid>
```

### URL-encode the project path

Replace `/` with `%2F` in the project path:
- `my-group/my-project` → `my-group%2Fproject`
- `group/subgroup/project` → `group%2Fsubgroup%2Fproject`

## Create Inline Discussion (Position-Based Comment)

**Endpoint:** `POST /projects/:id/merge_requests/:iid/discussions`

### Comment on a new (added) line

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
  flags:
    method: "POST"
    field:
      - "body=Comment text here"
      - "position[base_sha]=abc123..."
      - "position[head_sha]=def456..."
      - "position[start_sha]=ghi789..."
      - "position[position_type]=text"
      - "position[new_path]=src/main.py"
      - "position[new_line]=42"
```

### Comment on a deleted line

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
  flags:
    method: "POST"
    field:
      - "body=Comment text here"
      - "position[base_sha]=abc123..."
      - "position[head_sha]=def456..."
      - "position[start_sha]=ghi789..."
      - "position[position_type]=text"
      - "position[old_path]=src/main.py"
      - "position[old_line]=10"
```

### Comment on a modified line

Include both old and new positions:

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
  flags:
    method: "POST"
    field:
      - "body=Comment text here"
      - "position[base_sha]=abc123..."
      - "position[head_sha]=def456..."
      - "position[start_sha]=ghi789..."
      - "position[position_type]=text"
      - "position[old_path]=src/main.py"
      - "position[old_line]=10"
      - "position[new_path]=src/main.py"
      - "position[new_line]=12"
```

## List Discussions

**Endpoint:** `GET /projects/:id/merge_requests/:iid/discussions`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions"]
  flags:
    method: "GET"
```

### Response Structure

Each discussion contains:
- `id` - discussion ID (used for replies and resolution)
- `individual_note` - true if this is a standalone note, false if a threaded discussion
- `notes[]` - array of notes in the discussion:
  - `notes[].id` - note ID
  - `notes[].body` - comment text
  - `notes[].author.username` - author
  - `notes[].position` - position object (for inline comments):
    - `position.new_path` - file path in new version
    - `position.new_line` - line number in new version
    - `position.old_path` - file path in old version
    - `position.old_line` - line number in old version
  - `notes[].resolvable` - whether this note can be resolved
  - `notes[].resolved` - whether this note is resolved

## Reply to a Discussion

**Endpoint:** `POST /projects/:id/merge_requests/:iid/discussions/:discussion_id/notes`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions/<discussion_id>/notes"]
  flags:
    method: "POST"
    field:
      - "body=Reply text here"
```

## Resolve / Unresolve a Discussion

**Endpoint:** `PUT /projects/:id/merge_requests/:iid/discussions/:discussion_id`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions/<discussion_id>"]
  flags:
    method: "PUT"
    field:
      - "resolved=true"
```

To unresolve, set `resolved=false`.

## Error Handling

- **400 Bad Request with position error**: The specified line is not part of the diff. Verify the line number exists in the diff output. Fall back to a general comment via `glab_mr_note`.
- **404 Not Found**: Check that the project path is correctly URL-encoded and the MR IID is correct.
- **403 Forbidden**: The authenticated user may not have permission to comment on this MR.
