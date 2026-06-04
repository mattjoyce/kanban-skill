#!/usr/bin/env bash
# Bootstrap the shared kanban cards repo (NAS bare remote + local clone).
# Creates a bare git repo on the NAS and a working clone on this host, then
# prints what to set KANBAN_BASE to. Safe to re-run.
#
# Usage: setup.sh <bare-repo-path> [local-clone-dir]
#   e.g. setup.sh /Volumes/Projects/kanban.git ~/kanban
#
# On Linux hosts the NAS mounts elsewhere, so pass the host-local path, e.g.:
#   setup.sh /mnt/Projects/kanban.git ~/kanban
set -euo pipefail

BARE="${1:-}"
CLONE="${2:-$HOME/kanban}"
[ -n "$BARE" ] || { echo "Usage: $0 <bare-repo-path> [local-clone-dir]" >&2; exit 1; }

if [ ! -d "$BARE" ]; then
  echo "Creating bare repo at $BARE"
  git init --bare "$BARE"
else
  echo "Bare repo already exists at $BARE"
fi

if [ ! -d "$CLONE/.git" ]; then
  echo "Cloning into $CLONE"
  git clone "$BARE" "$CLONE"
  if ! git -C "$CLONE" rev-parse HEAD >/dev/null 2>&1; then
    printf '# Kanban cards\n\nShared card stack. One folder per project: `<slug>/cards/*.md`.\n' > "$CLONE/README.md"
    git -C "$CLONE" add README.md
    git -C "$CLONE" commit -m "init kanban cards repo"
    git -C "$CLONE" push -u origin HEAD
  fi
else
  echo "Clone already exists at $CLONE"
fi

echo
echo "Done. Add this to your shell profile (once per host):"
echo "  export KANBAN_BASE=\"$CLONE\""
