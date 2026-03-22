# Repository Improvement TODOs

Generated: 2026-03-21
Last Updated: 2026-03-22

## ✅ Completed

**P0 (Cleanup):**

- ✅ #2 - Remove commented-out code
- ✅ #7 - Resolve TODOs
- ✅ #20 - Remove unused files

**P1 (Consistency):**

- ✅ #1 - Consolidate mkSecret calls
- ✅ #11 - Extract common host config
- ⏭️ #9 - Rebuild aliases (already existed: `hms`, `snrs`)

**P2 (Quick Wins):**

- ✅ #3 - Simplify overlay application
- ✅ #6 - Add pre-commit hooks configuration
- ✅ #8 - Add update automation script
- ✅ #10 - Standardize home-manager module imports (removed inconsistent awesomewm config)
- ✅ #12 - Standardize secret naming (already consistent)
- ⏭️ #5 - Parameterize host configs (not needed with only 2 hosts)
- ⏭️ #17 - Age key backup warning (user has separate backup strategy)
- ⏭️ #19 - Optimize GC (current settings fine)
- ⏭️ #22 - Consolidate shell scripts (current ad-hoc approach works fine)

**P3 (Nice-to-Have):**

- ✅ #13 - Add per-directory READMEs
- ✅ #14 - Document custom modules
- ✅ #15 - Add architecture diagram
- ✅ #18 - Enable Nix daemon optimizations (framework only)
- ⏭️ #4 - Add flake-parts (too much effort for value)
- ⏭️ #16 - Pin inputs (current approach better)
- ⏭️ #21 - Extract fish logic (not needed)

---

## 📊 Remaining Items

**P3 - Deferred (to revisit later):**

- #23 - Add per-project devShells
- #24 - Template for new features

---

## 🎉 All Priority Tasks Complete

All P0, P1, P2, and P3 documentation tasks have been completed. The remaining items
(#23, #24) are deferred for future consideration when needed.

---

## 🎨 Deferred Items

### 23. **Add per-project devShells**

Consider if flake templates (#24) cover this use case first.

**Decision:** Revisit after implementing templates.

---

### 24. **Template for new features**

Add flake templates for common project types:

```text
templates/
├── rust/
│   ├── flake.nix
│   ├── .envrc
│   └── .gitignore
├── python/
│   ├── flake.nix
│   ├── .envrc
│   └── pyproject.toml
└── node/
    ├── flake.nix
    ├── .envrc
    └── package.json
```

**Usage:**

```bash
nix flake init -t ~/nix-config#rust
```

**Files to create:**

- `templates/rust/flake.nix`
- `templates/python/flake.nix`
- `templates/node/flake.nix`
- Update `flake.nix` to export templates

**Decision:** Deferred to revisit later.

---

## 🎯 Suggested Next Steps

1. **Quick documentation wins** (~1 hour):
   - #13 - Add READMEs
   - #15 - Add Mermaid diagram

2. **Code consistency** (~1 hour):
   - #3 - Clean up overlay code
   - #12 - Standardize secret naming

3. **Templates** (when needed):
   - #24 - Create project templates
   - #23 - Evaluate if devShells still needed
