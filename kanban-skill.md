---
name: kanban-ai
description: A skill to manage a simple Markdown-based Kanban board for AI agents.
---

# Kanban AI Skill

This skill allows you to manage a Kanban board using Markdown files in the `kanban/` directory.

Each Markdown file in this directory represents a card on the board. The status of the card is determined by the `status` field in the file's frontmatter.

## Card Fields

Each card's frontmatter supports the following fields:

- `id` — A unique numeric identifier. When creating a card, scan all existing cards in `kanban/`, find the highest `id`, and increment by 1. Start at `1` if the board is empty. Reference cards by this number.
- `status` — The column the card lives in: `backlog`, `todo`, `doing`, `done`, or `archive`.
- `priority` — `High` or `Normal`. Defaults to `Normal` if omitted.
- `blocked_by` — A list of card IDs that must be `done` before this card can move to `doing`. Example: `[3, 7]`. Omit or set to `[]` if nothing blocks it.
- `assignee` — (optional) Who owns the card.
- `due_date` — (optional) Target date.
- `tags` — (optional) List of labels.

## Instructions

### Creating a new card

To create a new card, create a new Markdown file in the `kanban/` directory. The filename should be a short, descriptive name for the task, using hyphens instead of spaces.

For example, to create a card for "Implement user authentication", you would create a file named `implement-user-authentication.md`.

The file should contain frontmatter with the fields above. The body of the file should contain a more detailed description of the task.

Example: `kanban/implement-user-authentication.md`
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

This task involves setting up user authentication using JWTs.

## Acceptance Criteria
- Users can register for a new account.
- Users can log in with their credentials.
- Authenticated users receive a JWT.
```

### Moving a card

To move a card to a different column, update the `status` field in the frontmatter of the corresponding Markdown file.

Before moving a card to `doing`, check its `blocked_by` list. All cards referenced in that list must have a status of `done` first. If any are not yet `done`, the card stays where it is.

For example, to move the `implement-user-authentication.md` card to `doing`, you would change the `status` in the file to `doing`.

### Viewing the board

To view the current state of the Kanban board, you need to list all the files in the `kanban/` directory and read the `status` from the frontmatter of each file.

You can then display the cards grouped by their status.
