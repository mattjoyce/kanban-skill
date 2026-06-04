#!/usr/bin/env bash
# Derive a stable project slug from the current git repo's remote URL.
# Using the remote (not the directory basename) means two clones of the
# same repo at different paths resolve to ONE shared card namespace,
# and two unrelated repos that happen to share a basename do not collide.
# Falls back to the toplevel directory name if no remote is configured.
# Usage: run inside a git repo: project_slug.sh
set -euo pipefail

url=$(git config --get remote.origin.url 2>/dev/null || true)

if [ -n "$url" ]; then
  # Normalize to "owner/repo": drop protocol, user@, the scp-style colon,
  # and the .git suffix; then take the last two path segments.
  norm=$(printf '%s' "$url" \
    | sed -E 's#^[a-zA-Z]+://##; s#^[^@/]*@##; s#:#/#; s#\.git$##')
  slug=$(printf '%s' "$norm" \
    | awk -F/ '{ if (NF>=2) print $(NF-1)"-"$NF; else print $NF }')
else
  slug=$(basename "$(git rev-parse --show-toplevel)")
fi

printf '%s\n' "$slug"
