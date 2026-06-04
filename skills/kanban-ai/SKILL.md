---
name: kanban-ai
description: Manage a Markdown-based Kanban board using card files in a central kanban repo. Use when the user asks to create, move, view, list, or manage tasks or cards on a kanban board, or when tracking work items across statuses like backlog, todo, doing, done, or archive.
---

# Kanban AI Skill

Manage a Kanban board as Markdown files in a central cards repository. Each file is a card. The board state is derived by reading all card files and grouping by `status` frontmatter.

## Setup

This skill requires the `KANBAN_BASE` environment variable pointing to your local clone of the shared kanban repo (e.g. `~/kanban`). The shared repo's `origin` is a **bare git repository on the NAS**, so every host and every agent pushes/pulls the same card stack. See `setup.sh` in the plugin root to bootstrap a clone.

The project slug is derived from the repo's **git remote URL** (not its directory name) via the bundled `project_slug.sh`. This means two clones of the same repo — or the same repo checked out on different hosts — resolve to one shared card namespace, and two unrelated repos that happen to share a directory name do not collide:

```bash
SCRIPTS_DIR=<this skill's scripts/ dir>   # locate via glob: **/kanban-ai/scripts
PROJECT_SLUG=$(bash "$SCRIPTS_DIR/project_slug.sh")
CARD_PATH="$KANBAN_BASE/$PROJECT_SLUG/cards"
mkdir -p "$CARD_PATH"
```

Archived cards live in `$CARD_PATH/archive/`.

If `KANBAN_BASE` is not set, or the current directory is not inside a git repo, inform the user and stop.

## Git Workflow (Required)

The kanban repo is shared. Always sync before and after making changes.

**Before reading or making any changes:**
```bash
git -C "$KANBAN_BASE" pull
```

**After creating, editing, moving, or archiving any card:**
```bash
git -C "$KANBAN_BASE" add -A
git -C "$KANBAN_BASE" commit -m "<brief description of change>"
git -C "$KANBAN_BASE" push
```

If `push` fails due to a remote divergence, pull and merge first:
```bash
git -C "$KANBAN_BASE" pull --rebase && git -C "$KANBAN_BASE" push
```

## Narrative Record (Required)

Treat cards as durable source material for future review. Do not rewrite or delete prior narrative content unless explicitly asked. When updating a card, append a brief narrative note to a `## Narrative` section at the end of the file. Focus on reasons, discoveries, insights, and decisions. Avoid transactional status-change logs unless they matter to the story. Use ISO dates.

Narrative entry format:

```markdown
## Narrative
- 2026-02-05: Discovered the auth flow must support device-based MFA; shifted approach to use WebAuthn. (by @assistant)
```

If the card has no `## Narrative` section, add it. If a change is minor (e.g., typo), skip the narrative note unless it carries meaningful insight.

When a card is moved to `done`, add enough narrative detail that a future reader can understand the card's story and outcome. Keep it coherent and complete without being verbose.

## Card Fields

Each card's frontmatter supports the following fields:

- `id` — Short unique identifier, 4-char base36 (e.g. `7wu`, `a3k9`). Generate with `new_id.sh "$CARD_PATH"`, which random-generates and checks for collisions across `$CARD_PATH` and `$CARD_PATH/archive/`. **Do not use max+1** — sequential ids collide when two agents create cards concurrently in separate workspaces. Reference cards by this id.
- `status` — Column: `backlog`, `todo`, `doing`, or `done`. (`archive` is a storage *location*, not a status — see Moving a Card.)
- `priority` — `High` or `Normal`. Defaults to `Normal` if omitted.
- `blocked_by` — List of card IDs that must be `done` before this card moves to `doing`. Example: `[3, 7]`. Omit or set to `[]` if unblocked.
- `assignee` — (optional) Owner of the card.
- `due_date` — (optional) Target date.
- `tags` — (optional) List of labels.

## Creating a Card

Create a new `.md` file in `$CARD_PATH/`. Filename should be kebab-case. Generate the id first: `id=$(bash "$SCRIPTS_DIR/new_id.sh" "$CARD_PATH")`.

If possible, include a Job Story using the structure "When [situation], I want to [motivation], so I can [expected outcome]." Do not force it; only add when it fits. If you add one, share it with the requester to confirm.

```markdown
---
id: a3k9
status: todo
priority: Normal
blocked_by: []
assignee: "@claude"
due_date: 2026-02-28
tags: [auth, backend]
---

# Implement User Authentication

Set up user authentication using JWTs.

## Acceptance Criteria
- Users can register for a new account.
- Users can log in with their credentials.
- Authenticated users receive a JWT.
```

After creating, commit and push.

## Moving a Card

Update the `status` field in frontmatter.

Before moving to `doing`, verify all IDs in `blocked_by` have status `done`. If any are not `done`, the card stays put.

Cards with `status: done` may be moved into `$CARD_PATH/archive/` to keep the main board tidy. This is a file-location move only; the card retains `status: done`. Create `archive/` if it does not exist.

After moving, commit and push.

## Viewing the Board

Helper scripts are bundled in the `scripts/` directory alongside this skill file. To locate them, find this skill's directory within the installed plugin (e.g., using `glob` for `**/kanban-ai/scripts/view_board.sh`).

Pull first, then run:

```bash
CARD_PATH="$KANBAN_BASE/$(basename "$(git rev-parse --show-toplevel)")/cards"
bash <SCRIPTS_DIR>/view_board.sh "$CARD_PATH"
```

Outputs cards grouped by status column, with priority and blocked_by flags inline. Archive cards are excluded from the board view unless explicitly requested.

## Searching and Filtering

Pull first. All scripts accept `$CARD_PATH` as the first argument and also search `$CARD_PATH/archive/` automatically.

### Search by Tag
```bash
bash <SCRIPTS_DIR>/search_by_tag.sh "$CARD_PATH" <tag>
```

### Search Content
```bash
bash <SCRIPTS_DIR>/search_content.sh "$CARD_PATH" "<search term>"
```

### Show Blocked Cards
```bash
bash <SCRIPTS_DIR>/show_blocked.sh "$CARD_PATH"
```

### List All Tags
```bash
bash <SCRIPTS_DIR>/list_tags.sh "$CARD_PATH"
```

### List All Cards
```bash
bash <SCRIPTS_DIR>/list_all_cards.sh "$CARD_PATH"
```
Output: All cards in pipe-delimited format (id|status|blocked_by|title), sorted by ID.

### Ready Work
The most useful agent query: cards in `todo`/`backlog` whose `blocked_by` are all `done` — i.e. what can be picked up right now.
```bash
bash <SCRIPTS_DIR>/ready.sh "$CARD_PATH"
```

### Cross-Project Board
Summarize every project under `KANBAN_BASE` at once — "what's on my plate everywhere" for agents working across workspaces.
```bash
bash <SCRIPTS_DIR>/board_all.sh "$KANBAN_BASE"
```

## Helper Scripts (internal)

- `new_id.sh "$CARD_PATH"` — emit a fresh collision-checked 4-char id. Always use this for new cards.
- `project_slug.sh` — print the remote-derived project slug (run inside the project repo).

**Note:** `<SCRIPTS_DIR>` refers to the `scripts/` directory next to this SKILL.md file.
