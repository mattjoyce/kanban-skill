---
name: kanban-ai
description: Manage a Markdown-based Kanban board using card files in a kanban/ directory. Use when the user asks to create, move, view, list, or manage tasks or cards on a kanban board, or when tracking work items across statuses like backlog, todo, doing, done, or archive.
---

# Kanban AI Skill

Manage a Kanban board as Markdown files in the `kanban/` directory. Each file is a card. The board state is derived by reading all files and grouping by `status`.

## Narrative Record (Required)

Treat cards as durable source material for future review. Do not rewrite or delete prior narrative content unless explicitly asked. When updating a card, append a brief narrative note to a `## Narrative` section at the end of the file. Focus on reasons, discoveries, insights, and decisions. Avoid transactional status-change logs unless they matter to the story. Use ISO dates.

Narrative entry format:

```markdown
## Narrative
- 2026-02-05: Discovered the auth flow must support device-based MFA; shifted approach to use WebAuthn. (by @assistant)
```

If the card has no `## Narrative` section, add it. If a change is minor (e.g., typo), skip the narrative note unless it carries meaningful insight.

When a card is moved to `done`, add enough narrative detail that a future reader can understand the card’s story and outcome. Keep it coherent and complete without being verbose.

## Card Fields

Each card's frontmatter supports the following fields:

- `id` — Unique numeric identifier. Scan existing cards in `kanban/`, take max + 1. Start at `1` if empty. Reference cards by this number.
- `status` — Column: `backlog`, `todo`, `doing`, `done`, or `archive`.
- `priority` — `High` or `Normal`. Defaults to `Normal` if omitted.
- `blocked_by` — List of card IDs that must be `done` before this card moves to `doing`. Example: `[3, 7]`. Omit or set to `[]` if unblocked.
- `assignee` — (optional) Owner of the card.
- `due_date` — (optional) Target date.
- `tags` — (optional) List of labels.

## Creating a Card

Create a new `.md` file in `kanban/`. Filename should be kebab-case.

If possible, include a Job Story using the structure “When [situation], I want to [motivation], so I can [expected outcome].” Do not force it; only add when it fits. If you add one, share it with the requester to confirm.

```markdown
---
id: 1
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

## Moving a Card

Update the `status` field in frontmatter.

Before moving to `doing`, verify all IDs in `blocked_by` have status `done`. If any are not `done`, the card stays put.

## Viewing the Board

Run the bundled script for a formatted board view:

```bash
bash ~/.claude/skills/kanban-ai/scripts/view_board.sh
```

Pass a custom kanban directory as an argument if it differs from `kanban/`:

```bash
bash ~/.claude/skills/kanban-ai/scripts/view_board.sh path/to/kanban
```

Outputs cards grouped by status column, with priority and blocked_by flags inline.

## Searching and Filtering

Helper scripts for searching the kanban board:

### Search by Tag
Find all cards with a specific tag:

```bash
bash ~/.claude/skills/kanban-ai/scripts/search_by_tag.sh kanban/ <tag>
```

Example:
```bash
bash ~/.claude/skills/kanban-ai/scripts/search_by_tag.sh kanban/ ai-discoverability
```

Output: Lists cards with that tag (ID, status, title)

### Search Content
Full-text search across card content:

```bash
bash ~/.claude/skills/kanban-ai/scripts/search_content.sh kanban/ "<search term>"
```

Example:
```bash
bash ~/.claude/skills/kanban-ai/scripts/search_content.sh kanban/ "temporal signals"
```

Output: Cards matching the search term with context lines

### Show Blocked Cards
List all cards that are blocked and their blockers:

```bash
bash ~/.claude/skills/kanban-ai/scripts/show_blocked.sh kanban/
```

Output: Cards with non-empty `blocked_by` field and what's blocking them

### List All Tags
Show tag usage across the board:

```bash
bash ~/.claude/skills/kanban-ai/scripts/list_tags.sh kanban/
```

Output: All tags sorted by usage count (most used first)

**Note:** All scripts take the kanban directory as the first argument. If omitted, they default to the current directory.
