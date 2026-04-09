# GitLab Discussions API Reference

## Overview

The GitLab Discussions API is used to list, reply to, and resolve discussions on merge requests. Use `glab_api` to call these endpoints.

## Prerequisites

### URL-encode the project path

Replace `/` with `%2F` in the project path:
- `my-group/my-project` → `my-group%2Fproject`
- `group/subgroup/project` → `group%2Fsubgroup%2Fproject`

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
- `individual_note` - true if standalone note, false if threaded discussion
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

### Filtering Unresolved Discussions

After fetching all discussions, filter client-side:
- Keep discussions where `notes[].resolvable == true` and `notes[].resolved == false`
- Skip discussions where all resolvable notes are already resolved

Alternatively, use `glab_mr_view <IID> --comments --unresolved` for a quick text overview (not structured JSON).

## Reply to a Discussion

**Endpoint:** `POST /projects/:id/merge_requests/:iid/discussions/:discussion_id/notes`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions/<discussion_id>/notes"]
  flags:
    method: "POST"
    raw_field:
      - "body=Reply text here"
```

## Resolve / Unresolve a Discussion

**Endpoint:** `PUT /projects/:id/merge_requests/:iid/discussions/:discussion_id`

```
glab_api args: ["projects/<encoded_project>/merge_requests/<iid>/discussions/<discussion_id>"]
  flags:
    method: "PUT"
    raw_field:
      - "resolved=true"
```

To unresolve, set `resolved=false`.

## Error Handling

- **404 Not Found**: Check that the project path is correctly URL-encoded and the MR IID is correct.
- **403 Forbidden**: The authenticated user may not have permission to comment on or resolve discussions in this MR.
