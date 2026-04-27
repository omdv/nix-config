#!/usr/bin/env bash
set -euo pipefail

cd /home/om/nix-config

echo "Updating flake inputs..."
nix flake update

echo "Checking flake..."
nix flake check

if ! jj diff --name-only flake.lock | grep -q .; then
  echo "No flake.lock changes to commit."
  exit 0
fi

echo "Committing flake.lock with jj..."
jj commit flake.lock -m "flake: update inputs $(date +%Y-%m-%d)"

BOOKMARK=""
if jj bookmark list | grep -q '^main:'; then
  BOOKMARK="main"
elif jj bookmark list | grep -q '^master:'; then
  BOOKMARK="master"
fi

if [[ -n "$BOOKMARK" ]]; then
  jj bookmark move "$BOOKMARK" --to @-
  echo "Moved bookmark '$BOOKMARK' -> @-"
else
  echo "No main/master bookmark found; skipped bookmark move."
fi

echo "✓ Flake inputs updated and committed"
echo ""
echo "Changed inputs:"
jj show --summary @-
