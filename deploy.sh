#!/usr/bin/env bash
# Deploy kanban-ai skill to all AI tool config directories.
# Run from anywhere: bash /mnt/Projects/kanban-skill/deploy.sh

set -e

SRC="$(cd "$(dirname "$0")/skills/kanban-ai" && pwd)"

TARGETS=(
  "$HOME/.claude/skills/kanban-ai"        # Claude Code (Pi also references this)
  "$HOME/.codex/skills/kanban-ai"         # Codex
  "$HOME/.config/goose/skills/kanban-ai"  # Goose
  "$HOME/.gemini/skills/kanban-ai"        # Gemini CLI
)

for target in "${TARGETS[@]}"; do
  mkdir -p "$target"
  rsync -a --delete "$SRC/" "$target/"
  echo "✓ $target"
done

echo
echo "All targets updated from: $SRC"
