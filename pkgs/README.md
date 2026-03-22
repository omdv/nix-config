# Custom Packages

This directory contains custom package derivations not available (or customized) from nixpkgs.

## Structure

```text
pkgs/
├── default.nix           # Package index (exports all packages)
├── oh-my-pi/            # Oh My Posh binary (self-contained)
├── pi-coding-agent/     # Pi coding agent wrapper
└── rustledger/          # Rustledger accounting CLI
```

## Available Packages

### `oh-my-pi` - Oh My Posh Prompt

**Type:** Prebuilt binary (Bun-compiled, self-contained)
**Version:** 13.11.1
**Source:** GitHub releases

A custom build of Oh My Posh (prompt theme engine) compiled with Bun into a self-contained binary.

**Usage:**

```nix
home.packages = [pkgs.oh-my-pi];
```

**Pattern:** Self-contained binary + manual patchelf

### `pi-coding-agent` - Pi Coding Agent

**Type:** Shell wrapper for npx
**Source:** npm package `@mariozechner/pi-coding-agent`

Wrapper script that ensures Node.js is available and delegates to npx.

**Usage:**

```nix
home.packages = [pkgs.pi-coding-agent];
# Then: pi [args]
```

**Pattern:** Shell script wrapper

### `rustledger` - Accounting CLI

**Type:** Prebuilt binary
**Version:** 0.9.1
**Source:** GitHub releases

Command-line accounting tool compatible with Ledger/hledger formats.

**Usage:**

```nix
home.packages = [pkgs.rustledger];
```

**Pattern:** Prebuilt binary + autoPatchelfHook

## Packaging Patterns

This repository uses three main patterns for custom packages:

### Pattern 1: Self-Contained Binary (oh-my-pi)

For binaries compiled with Bun or similar that are self-contained and don't need library resolution:

```nix
{
  stdenv,
  fetchurl,
  lib,
  patchelf,
}:
stdenv.mkDerivation {
  name = "oh-my-pi";
  src = fetchurl { url = "..."; sha256 = "..."; };

  dontUnpack = true;
  dontBuild = true;
  dontPatchELF = true;     # Manual patching instead
  dontStrip = true;

  nativeBuildInputs = [patchelf];

  installPhase = ''
    install -D -m755 $src $out/bin/omp
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/omp
  '';
}
```

**Key points:**

- `dontUnpack = true` - Source is already a binary
- Manual `patchelf --set-interpreter` - Set dynamic linker
- **Do NOT use** `autoPatchelfHook` for self-contained binaries

**When to use:** Bun-compiled binaries, Go static binaries, Rust static binaries

### Pattern 2: Prebuilt Binary with Dependencies (rustledger)

For prebuilt binaries that need system library linking:

```nix
{
  stdenv,
  fetchurl,
  lib,
  autoPatchelfHook,
}:
stdenv.mkDerivation {
  name = "rustledger";
  src = fetchurl { url = "..."; sha256 = "..."; };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [autoPatchelfHook];  # Auto-links libraries

  installPhase = ''
    install -D -m755 $src $out/bin/rustledger
  '';
}
```

**Key points:**

- `autoPatchelfHook` automatically finds and links required libraries
- Handles glibc, libgcc, and other common dependencies
- No manual patchelf needed

**When to use:** Prebuilt dynamically-linked binaries with library dependencies

### Pattern 3: Shell Wrapper (pi-coding-agent)

For wrapping existing commands with environment setup:

```nix
{
  writeShellScriptBin,
  nodejs_22,
}:
writeShellScriptBin "pi" ''
  export PATH="${nodejs_22}/bin:$PATH"
  exec npx @mariozechner/pi-coding-agent "$@"
''
```

**Key points:**

- `writeShellScriptBin` creates executable shell script
- Patch `$PATH` or environment as needed
- `exec` to replace shell process (clean process tree)
- `"$@"` forwards all arguments

**When to use:** npm/pip/gem packages, tools needing environment setup

## Adding a New Package

### 1. Create Package Directory

```bash
mkdir pkgs/newtool
```

### 2. Write Derivation

Create `pkgs/newtool/default.nix` using one of the patterns above.

**Example (prebuilt binary):**

```nix
{
  stdenv,
  fetchurl,
  lib,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "newtool";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/author/newtool/releases/download/v${version}/newtool-linux-amd64";
    sha256 = lib.fakeSha256;  # Get real hash on first build
  };

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [autoPatchelfHook];

  installPhase = ''
    install -D -m755 $src $out/bin/newtool
  '';

  meta = with lib; {
    description = "Description of newtool";
    homepage = "https://github.com/author/newtool";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
```

### 3. Add to Package Index

Edit `pkgs/default.nix`:

```nix
{pkgs}: {
  oh-my-pi = pkgs.callPackage ./oh-my-pi {};
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent {};
  rustledger = pkgs.callPackage ./rustledger {};
  newtool = pkgs.callPackage ./newtool {};  # Add this line
}
```

### 4. Test the Build

```bash
nix build .#newtool
./result/bin/newtool --version
```

### 5. Use in Configuration

The package is now available as `pkgs.newtool` via the `additions` overlay:

```nix
# In any NixOS or home-manager config
home.packages = [pkgs.newtool];
```

## Finding Hash Values

When you set `sha256 = lib.fakeSha256`, Nix will fail with the correct hash:

```bash
$ nix build .#newtool
error: hash mismatch in fixed-output derivation
  specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
  got:       sha256-RealHashWillBeHere123456789ABCDEF=
```

Copy the "got" hash into your derivation.

Alternatively, use `nix-prefetch-url`:

```bash
nix-prefetch-url https://example.com/binary.tar.gz
```

## Overlay Integration

Custom packages are automatically exposed via the `additions` overlay:

```nix
# overlays/default.nix
{
  additions = final: prev: import ../pkgs {pkgs = final;};
}
```

This means:

- ✅ Available in NixOS: `environment.systemPackages = [pkgs.oh-my-pi];`
- ✅ Available in home-manager: `home.packages = [pkgs.oh-my-pi];`
- ✅ Available in flake outputs: `nix build .#oh-my-pi`

## Updating Packages

### Update Version

1. Edit `pkgs/<name>/default.nix`:

   ```nix
   version = "2.0.0";  # Update version
   sha256 = lib.fakeSha256;  # Reset hash
   ```

2. Rebuild to get new hash:

   ```bash
   nix build .#newtool 2>&1 | grep "got:"
   ```

3. Update hash in derivation

4. Commit:

   ```bash
   git commit -m "pkgs/newtool: 1.0.0 -> 2.0.0"
   ```

### Automated Updates

For packages tracking GitHub releases, consider using `nix-update`:

```bash
nix run nixpkgs#nix-update -- pkgs.newtool
```

## Best Practices

- **Prefer nixpkgs:** Only package if not available or needs customization
- **Metadata:** Always include `meta` with description, homepage, license
- **Platforms:** Specify `platforms = platforms.linux` or specific architectures
- **Testing:** Build and test locally before committing
- **Versioning:** Pin to specific versions, avoid "latest" URLs
- **Licenses:** Respect and document package licenses
- **Maintainers:** Add yourself to `meta.maintainers` if maintaining long-term

## Common Issues

### Binary Not Found After Install

Check that installPhase creates `$out/bin/<name>`:

```bash
nix build .#newtool
ls -la result/bin/
```

### "No such file or directory" When Running

Binary needs patchelf to set interpreter. Use Pattern 1 or 2.

### "library not found" Errors

Use `autoPatchelfHook` (Pattern 2) to link required libraries.

### Hash Mismatch

Source file changed. Re-fetch hash with `nix-prefetch-url` or from build error.

## Related Documentation

- [NixOS Host Configuration](../hosts/README.md)
- [Home Manager Features](../home/om/features/README.md)
- [Overlays](../overlays/default.nix)
- [Repository Guidelines](../AGENTS.md)
