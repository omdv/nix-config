#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/home/om/nix-config"
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: auto-commit [--dry-run|-n] [--help|-h]

Commit current jj working changes with an AI-generated message,
then move main/master bookmark to the new commit (@-).
Does NOT push.

Options:
  -n, --dry-run   Generate and print message, but do not commit
  -h, --help      Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "$REPO_DIR"

CHANGED_PATHS="$(jj diff --name-only 2>/dev/null || true)"
if [[ -z "${CHANGED_PATHS//[[:space:]]/}" ]]; then
  echo "No changes detected. Nothing to do."
  exit 0
fi

DIFF_SUMMARY="$(jj diff --summary 2>/dev/null || true)"
DIFF_GIT="$(jj diff --git 2>/dev/null | head -c 12000 || true)"

PROMPT=$(cat <<EOF
You are generating a git/jj commit message.

Rules:
- Output only commit message text.
- Use Conventional Commits style.
- Keep subject line <= 72 characters.
- Imperative mood, concise, specific.
- Add a short body only if needed.

Repository diff summary:
${DIFF_SUMMARY}

Repository diff (truncated):
${DIFF_GIT}
EOF
)

MSG="$(aichat --no-stream "$PROMPT" 2>/dev/null || true)"
MSG="$(printf '%s' "$MSG" | sed '/^[[:space:]]*$/d' | sed 's/^```.*$//g' | sed 's/^"//; s/"$//')"

if [[ -z "${MSG//[[:space:]]/}" ]]; then
  MSG="chore: automated snapshot"
fi

echo "Generated commit message:"
echo "----------------------------------------"
echo "$MSG"
echo "----------------------------------------"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Dry-run enabled; skipping commit."
  exit 0
fi

jj commit -m "$MSG"

echo "Committed successfully."

BOOKMARK=""
if jj bookmark list | grep -q '^main:'; then
  BOOKMARK="main"
elif jj bookmark list | grep -q '^master:'; then
  BOOKMARK="master"
else
  echo "Neither 'main' nor 'master' bookmark exists; skipping bookmark move." >&2
  exit 1
fi

jj bookmark move "$BOOKMARK" --to @-
echo "Moved bookmark '$BOOKMARK' -> @-"
echo "Done. No push performed."
