{ writeShellScriptBin, jujutsu, aichat, coreutils, gnused }:
writeShellScriptBin "jjcai" ''
  set -euo pipefail

  export PATH="${jujutsu}/bin:${aichat}/bin:${coreutils}/bin:${gnused}/bin:$PATH"

  CHANGED_PATHS="$(jj diff --name-only 2>/dev/null || true)"
  if [[ -z "''${CHANGED_PATHS//[[:space:]]/}" ]]; then
    echo "No changes detected. Nothing to commit."
    exit 0
  fi

  DIFF_SUMMARY="$(jj diff --summary 2>/dev/null || true)"
  DIFF_GIT="$(jj diff --git 2>/dev/null | head -c 20000 || true)"

  PROMPT=$(cat <<EOF
You generate a commit message for a Jujutsu (jj) commit.

Hard requirements:
- Output only raw commit message text (no markdown, no quotes, no fences).
- Use Conventional Commits: type(scope): subject
- Allowed types: feat, fix, refactor, perf, docs, test, build, ci, chore, revert
- Subject must be imperative, specific, and <= 72 chars.
- If multiple logical changes exist, summarize the dominant one in subject.
- Add body only when needed for non-obvious context.
- Body lines should be concise and wrapped naturally.
- Do not mention AI, tooling, prompts, or that this was auto-generated.
- Avoid vague subjects like "update", "changes", "cleanup" unless truly unavoidable.

Context:
Changed paths:
''${CHANGED_PATHS}

Diff summary:
''${DIFF_SUMMARY}

Diff (truncated):
''${DIFF_GIT}
EOF
)

  MSG="$(aichat --no-stream "$PROMPT" 2>/dev/null || true)"
  MSG="$(printf '%s' "$MSG" | sed '/^[[:space:]]*$/d' | sed 's/^```.*$//g' | sed 's/^"//; s/"$//')"

  if [[ -z "''${MSG//[[:space:]]/}" ]]; then
    MSG="chore: snapshot current changes"
  fi

  echo "Generated commit message:"
  echo "----------------------------------------"
  echo "$MSG"
  echo "----------------------------------------"

  jj commit -m "$MSG"

  BOOKMARK=""
  if jj bookmark list | grep -q '^main:'; then
    BOOKMARK="main"
  elif jj bookmark list | grep -q '^master:'; then
    BOOKMARK="master"
  else
    echo "Neither 'main' nor 'master' bookmark exists; skipping bookmark move." >&2
    exit 0
  fi

  jj bookmark move "$BOOKMARK" --to @-
  echo "Moved bookmark '$BOOKMARK' -> @-"
''