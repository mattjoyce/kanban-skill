#!/usr/bin/env bash
# Cross-project board: one summary line per project under KANBAN_BASE.
# Answers "what's on my plate everywhere" for agents spanning workspaces.
# Usage: board_all.sh [KANBAN_BASE]   (defaults to $KANBAN_BASE)
set -euo pipefail

BASE="${1:-${KANBAN_BASE:-}}"
[ -n "$BASE" ] || { echo "Set KANBAN_BASE or pass a base path" >&2; exit 1; }
[ -d "$BASE" ] || { echo "Base '$BASE' not found" >&2; exit 1; }

field() { awk -v f="$2" '/^---$/{fm++;next} fm==1 && $0 ~ "^"f":"{sub("^"f":[ \t]*","");print;exit}' "$1"; }

printf "%-28s %-9s %-7s %-8s %-7s\n" "PROJECT" "backlog" "todo" "doing" "done"
for proj in "$BASE"/*/; do
  cp="${proj%/}/cards"
  [ -d "$cp" ] || continue
  unset c; declare -A c
  for s in backlog todo doing done; do c[$s]=0; done
  for f in "$cp"/*.md; do
    [ -f "$f" ] || continue
    s=$(field "$f" status)
    [ -n "${s:-}" ] && [ -n "${c[$s]+x}" ] && c[$s]=$(( c[$s] + 1 ))
  done
  printf "%-28s %-9s %-7s %-8s %-7s\n" "$(basename "${proj%/}")" \
    "${c[backlog]}" "${c[todo]}" "${c[doing]}" "${c[done]}"
done
