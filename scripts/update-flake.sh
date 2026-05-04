#!/usr/bin/env bash
set -euo pipefail

cd /home/om/nix-config

echo "Updating flake inputs..."
nix flake update

echo "Checking flake..."
nix flake check

if git diff --quiet -- flake.lock; then
  echo "No flake.lock changes to commit."
  exit 0
fi

echo "Committing flake.lock with git..."
git add flake.lock
git commit -m "flake: update inputs $(date +%Y-%m-%d)"

echo "✓ Flake inputs updated and committed"
echo ""
echo "Changed inputs:"
git show --stat --oneline --no-patch HEAD
