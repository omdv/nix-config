---
name: context-optimization
description: Compress context cost during exploratory work using checkpoint/rewind. Use automatically for any investigation requiring 5+ tool calls before making a decision.
---

# Context Optimization via Checkpoint/Rewind

Efficiently explore codebases and investigate issues without bloating context.

## Required Decision Gate (Strict Mode)

Before any non-trivial task, run this gate:

1. **Will this require exploration?** (multiple files, unknown root cause, option analysis)
2. **Will I likely need >3 tool calls before acting?**

If either answer is **yes**, you **MUST checkpoint first**.

Use checkpoint/rewind by default for:

- 🔍 **Deep investigation**: 3+ read/grep/find/lsp calls
- 🐛 **Bug hunting**: tracing cause across modules
- 📊 **Performance analysis**: testing multiple bottlenecks
- 🏗️ **Architecture review**: understanding interactions
- 🔎 **Dependency tracing**: following call chains
- 🤔 **Comparing approaches** before implementation

Only skip checkpoint for clearly direct actions (single-file, obvious edit, immediate execution).
## How It Works

```
1. checkpoint(goal: "specific investigation goal")
   ↓
2. Perform exploratory work freely
   - read multiple files
   - grep across codebase  
   - run LSP queries
   - check git history
   - anything needed to understand the issue
   ↓
3. rewind(report: "1-3 paragraph summary of findings")
```

**Result**: All intermediate exploration (steps 2) is removed from LLM context and replaced by your concise report. The full exploration is preserved in session history for debugging, but doesn't cost tokens.

**Context savings**: 90%+ for typical investigations (15-20 tool calls → 1 summary)

## Usage Pattern

### Investigation Template

```typescript
// Start every investigation with checkpoint
checkpoint(goal: "Find why API endpoint /users/:id is slow")

// Explore freely - context cost doesn't matter yet
read src/api/users.ts
grep "query" -r src/models/
lsp references src/models/User.ts:42 User.find
read src/database/connection.ts
bash git log --oneline -10 src/api/users.ts

// After finding the answer, compress everything
rewind(report: "Bottleneck identified: N+1 query in User.posts relationship. Line 42 calls .posts.all for each user, executing 1+N queries. Fix: Add .includes(:posts) to eager load. This reduces 101 queries to 2 queries for 100 users.")
```

### Report Quality Guide

**Good reports** (compress well):
```
"Bug found: JWT expiry validation skipped in auth/middleware.ts:89. 
Token acceptance logic checks signature but not exp claim. 
Attacker with expired but signed token can authenticate. 
Fix: Add exp < now check before signature verification."
```

**Bad reports** (defeat the purpose):
```
"I started by reading auth.ts which has 500 lines. Then I checked 
middleware.ts and found some JWT code. I searched for 'jwt' and got
many results. After reading database.ts and api.ts, I noticed that..."
```

**Report checklist**:
- ✅ States what you found (bug/bottleneck/answer)
- ✅ Explains where (file:line or component name)
- ✅ Describes impact/severity
- ✅ Suggests concrete next action
- ❌ Does NOT narrate your exploration process
- ❌ Does NOT include full file contents
- ❌ Does NOT list every tool call you made

## Automatic Application

### Self-Trigger Pattern

Before any investigation, ask yourself:

> "Will I need more than 5 tool calls to answer this?"

If YES → **Start with checkpoint immediately**

```typescript
// ✅ Correct: Checkpoint before starting
checkpoint(goal: "Trace authentication flow from login to session creation")
// ... exploration happens ...
rewind(report: "Auth flow: login → verify_credentials → create_session → set_cookie")

// ❌ Wrong: Exploration without checkpoint
read auth/login.ts      // 200 lines in context
read auth/session.ts    // 300 lines in context
read middleware/auth.ts // 250 lines in context
// Now stuck with 750 lines of context that could have been 50 words
```

### Common Scenarios

| Task | Checkpoint? | Why |
|------|-------------|-----|
| "Find the bug in authentication" | ✅ YES | Will read auth code, middleware, tests, config |
| "Add logging to this function" | ❌ NO | Single file, direct action |
| "Understand how payments work" | ✅ YES | Multi-file system investigation |
| "Fix typo in comment" | ❌ NO | No investigation needed |
| "Why is this endpoint slow?" | ✅ YES | Performance investigation needs profiling |
| "Update version in package.json" | ❌ NO | Direct action, no exploration |

## Rules (Strict)

1. **Checkpoint-before-explore is mandatory**: Do not start exploratory tool calls without checkpoint.

2. **Rewind-before-yield is mandatory**: If checkpoint is active, you MUST call rewind before stopping/responding.

3. **Exactly one active checkpoint**: Never nest checkpoints.

4. **Report discipline**: Keep rewind report concise (target 50-150 words, hard cap 200). Include: finding, location, impact, next action.

5. **Allowed skip cases only**: You may skip checkpoint only for direct, low-ambiguity tasks that require minimal exploration.
## Advanced Patterns

### Multi-Stage Investigation

When investigation has distinct phases:

```typescript
// Phase 1: Find the bug
checkpoint(goal: "Locate source of memory leak")
// ... exploration ...
rewind(report: "Leak in cache.ts:156 - WeakMap not cleaning up listeners")

// Phase 2: Understand fix requirements  
checkpoint(goal: "Determine safe fix for cache listener leak")
// ... more exploration ...
rewind(report: "Safe fix: Add cleanup in destroy() method. No breaking changes needed.")

// Phase 3: Implement
// No checkpoint - direct implementation from here
```

### Abandoned Investigations

If you checkpoint but find nothing useful:

```typescript
checkpoint(goal: "Check if issue is in payment module")
// ... exploration ...
rewind(report: "Payment module is not the cause. Issue must be elsewhere. Next: check email service.")
```

Even negative results are valuable when compressed!

## Context Savings Math

**Without checkpoint:**
```
User: "Why is this slow?"
Assistant: read api.ts (500 lines)
Tool: [500 lines]
Assistant: read db.ts (400 lines)  
Tool: [400 lines]
Assistant: grep "query" (50 matches)
Tool: [200 lines of matches]
Assistant: read model.ts (300 lines)
Tool: [300 lines]
Total: ~1400 lines in context
```

**With checkpoint:**
```
User: "Why is this slow?"
Assistant: checkpoint(goal="Find performance issue")
Assistant: [same exploration, but...]
Assistant: rewind(report="N+1 query in User.posts. Fix: eager load")
Total: ~50 words in context (96% savings)
```

## Monitoring

Check checkpoint status:
```bash
/checkpoint-status    # See active checkpoint details
/checkpoint-abandon   # Cancel checkpoint without rewinding (rare)
```

## Best Practices

1. **Be specific in goals**: "Find auth bug" → "Find why JWT tokens expire too soon"

2. **Checkpoint early**: Don't wait until you've already used 10 tool calls

3. **Multiple small checkpoints > one huge**: Break investigations into phases

4. **Test assumptions first**: If you're 80% sure where the issue is, check that first before checkpointing for a full investigation

5. **Don't checkpoint for execution**: Checkpoints are for **reading/understanding**, not for **writing/modifying**

## Integration with Other Features

- **Works with compaction**: Checkpoint/rewind happens before compaction triggers
- **Visible in /tree**: Can navigate to see full exploration if needed
- **Survives restarts**: Checkpoint state persists across crashes
- **Composable with branching**: Can checkpoint on any branch

## Success Metrics

After using this skill, you should see:

- 📉 **Lower token usage** per task (50-90% reduction on investigations)
- 🎯 **More focused context** (summaries instead of raw data)
- 🚀 **Faster investigations** (no fear of context bloat)
- 🧠 **Better memory** (can investigate deeper without hitting limits)

## Troubleshooting

**"I forgot to rewind and yielded"**
→ Immediately continue and call `rewind` with findings. Treat this as a workflow violation and self-correct before any new work.

**"My report is too long"**
→ Focus on: What you found, where it is, what to do. Skip the journey, keep the destination.

**"Should I checkpoint this?"**
→ If unsure, checkpoint. The overhead is small, the savings are large.

**"I checkpointed but found nothing"**
→ Still rewind! Report "No issues found in X" is valuable and costs almost nothing.

## Remember

🎯 **Checkpoint before exploring, not after**

The goal is to make exploration free. Once you've already used context, checkpointing is pointless.

Think of it like:
- 🚫 **Wrong**: Drive 100 miles, then realize you should have tracked mileage
- ✅ **Right**: Reset trip odometer before driving, check distance after

**Default mindset (strict)**: checkpoint unless you can explicitly justify a direct-action skip in one sentence.
