#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <flake-hostname> <ssh-target> [--no-os] [--no-home] [--dry]"
  echo "Example: $0 hadron om@192.168.1.189"
  exit 1
fi

FLAKE_HOST="$1"
SSH_TARGET="$2"
shift 2

DO_OS=true
DO_HOME=true
DRY=false

for arg in "$@"; do
  case "$arg" in
    --no-os) DO_OS=false ;;
    --no-home) DO_HOME=false ;;
    --dry) DRY=true ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REMOTE_DIR="~/nix-config"

RSYNC_FLAGS=(-az --delete --exclude '.git' --exclude 'result' --exclude '.direnv')
if [ "$DRY" = true ]; then
  RSYNC_FLAGS+=(--dry-run --itemize-changes)
fi

echo "==> Syncing repo to $SSH_TARGET:$REMOTE_DIR"
rsync "${RSYNC_FLAGS[@]}" "$REPO_DIR/" "$SSH_TARGET:$REMOTE_DIR/"

if [ "$DRY" = true ]; then
  echo "==> Dry run complete (sync only)."
  exit 0
fi

if [ "$DO_OS" = true ]; then
  echo "==> Applying NixOS config: $FLAKE_HOST"
  ssh "$SSH_TARGET" "cd $REMOTE_DIR && nh os switch . -H $FLAKE_HOST"
fi

if [ "$DO_HOME" = true ]; then
  echo "==> Applying Home Manager config: om@$FLAKE_HOST"
  ssh "$SSH_TARGET" "cd $REMOTE_DIR && nh home switch . -c om@$FLAKE_HOST"
fi

echo "==> Deploy complete for $FLAKE_HOST"
