#!/usr/bin/env bash
# Generate a collision-resistant short card id (4-char base36),
# unique within CARD_PATH (and its archive/).
# Random generation — not max+1 — so concurrent agents in separate
# workspaces don't pick the same id.
# Usage: new_id.sh <card-path>
set -eu

CARD_PATH="${1:-.}"

existing=$(grep -h "^id:" "$CARD_PATH"/*.md "$CARD_PATH"/archive/*.md 2>/dev/null \
  | sed 's/^id:[[:space:]]*//' | tr -d '"' | tr -d ' ' || true)

gen() {
  local chars=abcdefghijklmnopqrstuvwxyz0123456789 out= i
  for i in 1 2 3 4; do
    out+=${chars:$((RANDOM % 36)):1}
  done
  printf '%s' "$out"
}

for _ in $(seq 1 50); do
  cand=$(gen)
  if ! printf '%s\n' "$existing" | grep -qx "$cand"; then
    echo "$cand"
    exit 0
  fi
done

echo "ERR: could not generate a unique id after 50 attempts" >&2
exit 1
