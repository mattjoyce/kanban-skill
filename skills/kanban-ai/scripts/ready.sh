#!/usr/bin/env bash
# List "ready" cards: status todo or backlog whose blockers are all done.
# This is the most useful agent query — what can I actually pick up next.
# Usage: ready.sh <card-path>
set -euo pipefail

CARD_PATH="${1:-.}"

field() { awk -v f="$2" '/^---$/{fm++;next} fm==1 && $0 ~ "^"f":"{sub("^"f":[ \t]*","");print;exit}' "$1"; }
ctitle() { awk '/^---$/{fm++;next} fm==2 && /^# /{sub("^# ","");print;exit}' "$1"; }

# id -> status across active + archived cards
declare -A st
for f in "$CARD_PATH"/*.md "$CARD_PATH"/archive/*.md; do
  [ -f "$f" ] || continue
  id=$(field "$f" id); s=$(field "$f" status)
  [ -n "$id" ] && st["$id"]="$s"
done

echo "=== Ready ==="
found=0
for f in "$CARD_PATH"/*.md; do
  [ -f "$f" ] || continue
  s=$(field "$f" status)
  case "$s" in todo|backlog) ;; *) continue ;; esac

  blocked=$(field "$f" blocked_by | tr -d '[] "')
  ok=1
  if [ -n "$blocked" ]; then
    IFS=',' read -ra ids <<< "$blocked"
    for b in "${ids[@]}"; do
      [ -n "$b" ] || continue
      [ "${st[$b]:-}" = "done" ] || ok=0
    done
  fi

  if [ "$ok" = 1 ]; then
    id=$(field "$f" id); t=$(ctitle "$f"); p=$(field "$f" priority)
    line="  #${id} [${s}] ${t}"
    [ "$p" = "High" ] && line="$line [HIGH]"
    echo "$line"
    found=1
  fi
done
[ "$found" = 0 ] && echo "  (nothing ready)"
