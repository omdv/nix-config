#!/usr/bin/env bash
set -e

echo "Updating flake inputs..."
nix flake update

echo "Checking flake..."
nix flake check

echo "Committing flake.lock..."
git add flake.lock
git commit -m "flake: update inputs $(date +%Y-%m-%d)"

echo "✓ Flake inputs updated and committed"
echo ""
echo "Changed inputs:"
git show --stat
