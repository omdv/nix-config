---
name: analyze-repo
description: Analyze a git repository before code reading using five diagnostic git commands (churn hotspots, contributor concentration, bug hotspots, commit velocity, and firefighting signals). Use when the user says "analyze repo" or asks for a quick repository health scan.
---

# Analyze Repo

Run this skill when the user asks to **"analyze repo"**.

## What this does

This skill runs five git commands from the article:

- Most frequently changed files in the last year
- Contributor distribution (bus factor signal)
- Bug-fix hotspot files
- Commit activity by month
- Revert/hotfix/emergency patterns

## Execution

From the target repository root, run these commands directly:

```bash
# 1) Most frequently changed files (top 20, last year)
git log --format=format: --name-only --since="1 year ago" \
  | sed '/^$/d' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -20

# 2) Contributor distribution (bus factor signal)
git shortlog -sn --no-merges --all

# 3) Bug-fix hotspot files (top 20)
git log -i -E --grep="fix|bug|broken" --name-only --format='' --all \
  | sed '/^$/d' \
  | sort \
  | uniq -c \
  | sort -nr \
  | head -20

# 4) Commit activity by month
git log --format='%ad' --date=format:'%Y-%m' --all \
  | sort \
  | uniq -c

# 5) Revert/hotfix/emergency patterns (last year)
git log --oneline --since="1 year ago" --all \
  | grep -iE 'revert|hotfix|emergency|rollback' || true
```

## Required output format

After running the commands:

1. Show the raw output sections from all five commands.
2. Provide a concise summary with these headings:
   - Churn hotspots
   - Ownership / bus factor risk
   - Bug hotspot overlap
   - Project momentum trend
   - Firefighting signals
3. End with 3-5 practical next steps based on the findings.

## Notes

- If commit message quality is poor, explicitly mention reduced confidence for bug/firefighting inference.
- If not in a git repository, tell the user and ask for the correct repo path.
