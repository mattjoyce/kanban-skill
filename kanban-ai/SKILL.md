---
name: kanban-ai
description: Manage a Markdown-based Kanban board using card files in a kanban/ directory. Use when the user asks to create, move, view, list, or manage tasks or cards on a kanban board, or when tracking work items across statuses like backlog, todo, doing, done, or archive.
---

# Kanban AI Skill

Manage a Kanban board as Markdown files in the `kanban/` directory. Each file is a card. The board state is derived by reading all files and grouping by `status`.

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
bash kanban-ai/scripts/view_board.sh
```

Pass a custom kanban directory as an argument if it differs from `kanban/`:

```bash
bash kanban-ai/scripts/view_board.sh path/to/kanban
```

Outputs cards grouped by status column, with priority and blocked_by flags inline.
