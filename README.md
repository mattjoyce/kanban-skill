# kanban-ai

A Markdown-based Kanban board skill for Claude Code.

Cards live as `.md` files in a `kanban/` directory. The board is derived at read-time — no database, no server. Status is tracked in YAML frontmatter.

## Install

Add the `.skill` file to your Claude Code skills directory, or copy `kanban-ai/` into `~/.claude/skills/`.

## Card Fields

| Field        | Required | Description                                                                 |
|--------------|----------|-----------------------------------------------------------------------------|
| `id`         | Yes      | Auto-increment integer. Max existing + 1, start at 1.                       |
| `status`     | Yes      | `backlog` · `todo` · `doing` · `done` · `archive`                           |
| `priority`   | No       | `High` or `Normal` (default)                                                |
| `blocked_by` | No       | List of card IDs that must be `done` first. e.g. `[2, 5]`                   |
| `assignee`   | No       | Who owns the card                                                           |
| `due_date`   | No       | Target date                                                                 |
| `tags`       | No       | List of labels                                                              |

## View the Board

```bash
bash kanban-ai/scripts/view_board.sh
```

## Example Card

`kanban/setup-ci.md`:

```markdown
---
id: 3
status: todo
priority: High
blocked_by: [1, 2]
tags: [devops]
---

# Set Up CI Pipeline

Configure GitHub Actions for automated testing.
```

## Rules

- A card cannot move to `doing` until all cards in its `blocked_by` list are `done`.
- IDs are assigned by scanning existing cards and incrementing the highest.
