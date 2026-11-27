## NixOS configuration

Personal NixOS + home-manager configuration as a flake. Native machines: `framework` (laptop) and `homelab` (headless server). `emulator` is a disposable ARM NixOS guest running under Unkernel in a web browser.

## Structure

```text
flake.nix          -- inputs, outputs, wiring
hosts/             -- NixOS system configs per machine
home/om/           -- home-manager config for user om
  global/          -- always loaded (git, kitty, fonts)
  features/        -- opt-in feature bundles
modules/           -- custom NixOS and HM modules
pkgs/              -- custom package derivations
overlays/          -- nixpkgs overlays
lib/               -- mkHost, mkHome, mkSecret helpers
```

## Machines

**framework** -- Framework 13 laptop

- xanmod kernel, systemd-boot
- i3wm, picom, polybar, rofi, dunst
- catppuccin-mocha colorscheme
- pipewire, lightdm
- Mullvad VPN, Tailscale
- libvirt, Steam, Java
- zram swap, btrfs with monthly scrub
- Paseo daemon for AI coding agents
- auto-cpufreq, xss-lock + i3lock

**homelab** -- headless server

- k3s, Tailscale
- sops-nix secrets

**emulator** -- ephemeral terminal environment

- Real NixOS systemd and integrated Home Manager, then login Fish as `om`
- Starship, Git, bat, fzf, fd, eza, jq, ripgrep and the selected Nixvim configuration
- No personal secrets, guest internet access, persistent disk or host-directory mounts
- Existing native machines keep standalone Home Manager

## Key tools

| Tool | Config |
|---|---|
| shell | fish |
| terminal | kitty + zellij |
| editor | neovim (nixvim) with LSP, treesitter, catppuccin |
| mail | neomutt + mbsync + msmtp |
| browser | Brave |
| passwords | pass |
| backups | restic |
| AI agent daemon | Paseo (`hosts/common/optional/paseo.nix`) |

## Commands

```bash
# rebuild system
sudo nixos-rebuild switch --flake .#framework

# apply home-manager
home-manager switch --flake .#om@framework

# format
nix fmt

# edit secrets
sops home/om/secrets.yaml
```

## Emulator guest

`emulator` is the machine identity; a web browser is its execution surface.
The existing host, home, package and workflow paths are renamed in place,
not duplicated alongside the former names; there are no compatibility aliases.
The rename is not rebuilt or boot-tested: commands below describe the current
interfaces, while recorded image-size and boot evidence predates the rename.

The image contains the whole selected system and home closure. It is not a
BusyBox shell with a few mounted packages. Unkernel is pinned in
`pkgs/emulator.nix`; the browser loads its kernel, runtime, terminal and image
from the same static release. A working WebAssembly JSPI implementation is
required; Chromium 157 was used locally. Allow memory for the 2 GiB guest plus
browser/runtime overhead. The guest is experimental, not a hostile-code
isolation guarantee; do not enter credentials.

| File | Owns |
|---|---|
| `hosts/emulator/default.nix` | ARM system, user and upstream HM integration |
| `hosts/emulator/unkernel.nix` | Unkernel boot compatibility and activation/terminal services |
| `home/om/emulator.nix` | Explicit portable tool selection and emulator-only overrides |
| `pkgs/emulator.nix` | Pinned dependencies, full root image, static site and local preview |
| `hosts/emulator/index.html` | Visitor-side boot controls, interactive terminal, diagnostics and fresh restart |
| `.github/workflows/emulator.yml` | Native ARM build, HTTP verification, immutable publication and rollback |

`lib/mkHost.nix` accepts explicit module paths; `flake.nix` registers the new
host and outputs. No native host directories move, no root manifest is added,
and `lib/mkHome.nix`, shared feature modules and package overlays are unchanged.

### Build and run locally

The machine has one public name, `emulator`: build produces the complete static
bundle; run starts a local preview with HTTP byte-range support for its image.
Production static hosting replaces the preview server. Image and runtime builds
are internal dependencies, not separate public outputs.

These outputs are architecture-qualified even on x86. Building needs a native
ARM builder or deliberately configured aarch64 emulation. The preview also
contains ARM Node, so running it on x86 requires emulation.

```bash
# Build the complete bundle (result/index.html, image.ext4 and runtime assets).
nix build path:.#packages.aarch64-linux.emulator

# Preview it on 127.0.0.1; PORT defaults to 8080.
nix run path:.#apps.aarch64-linux.emulator
```

Open `http://127.0.0.1:8080/` and press **Boot**. `path:.` includes newly added
files before they are committed; these commands do not activate either native
machine. See [host notes](hosts/README.md#emulator---disposable-browser-guest)
for boot integration and measured local behavior.

#### Manual browser verification

Use the local preview above, or visit the published `index.html`, in a compatible
browser and press **Boot**. In the terminal, check `whoami` returns `om`,
`systemctl is-system-running` reports `running`, and
`systemctl is-active home-manager-om` reports `active`.
Open a scratch file in Neovim, edit and save it, and check terminal resizing.
Use **Fresh restart** and confirm the scratch file is gone.

CI verifies storage and HTTP delivery only; it does not launch Chromium or prove
that the guest boots. Browser testing is manual, with no separate smoke runner.

Guest writes live only in RAM. **Fresh restart**, closing or reloading the page
discards them, including edited configuration. Immutable asset caches are not
guest persistence. This release has no Wisp relay or guest network: package
downloads/builds inside the guest are not supported. The hosting page and its
publisher remain trusted; a checksum served by that page does not authenticate
a malicious publisher.

### GitHub publication prerequisites

The R2 bucket and custom domain are configured. Neither CI job starts a local
server or launches a browser; publication needs Python and the S3 SDK, not Chromium.
Do not commit, push or publish without separate authorization. PR jobs build without
storage credentials. Only a successful `main` push/manual run can enter the
`emulator` deployment environment.

The build job retains a GitHub artifact for transfer between jobs. The separate
`publish` job's **Upload to Cloudflare R2 and verify HTTP delivery** step uploads
that bundle to R2; it runs only after the build succeeds and any environment
approval is granted. The GitHub artifact itself is not the hosted release.

Create/protect that GitHub environment with required reviewers and a `main`-only
deployment policy. Configure these **environment-scoped** values:

| Name | Kind | Meaning |
|---|---|---|
| `EMULATOR_S3_ENDPOINT` | Variable | `https://<ACCOUNT_ID>.r2.cloudflarestorage.com` (R2 S3 API, not the public site URL) |
| `EMULATOR_BUCKET` | Variable | `nix-emulator` |
| `EMULATOR_PUBLIC_URL` | Variable | `https://nix.kblb.io` (base URL, without `index.html`) |
| `AWS_DEFAULT_REGION` | Variable | `auto` |
| `AWS_ACCESS_KEY_ID` | Secret | R2 Access Key ID from a bucket-scoped Object Read & Write token |
| `AWS_SECRET_ACCESS_KEY` | Secret | Corresponding R2 Secret Access Key; never put it in Nix |

The workflow already attaches its publication job to the GitHub environment
with `environment: emulator`; no additional UI attachment is needed. Use the
token's S3 credentials, not its bearer token or Wrangler OAuth credentials.

R2 supports atomic conditional PUT (`If-Match`/`If-None-Match`). Publication
uses these for immutable uploads, promotion and rollback; it does not depend
on conditional DELETE. Restrict the token to the dedicated bucket. No release
deletion is used. Assets must fit R2's single-PUT limit.

The entry URL is `https://nix.kblb.io/index.html`; release pointers explicitly
target `/releases/<revision>/index.html`. R2 does not resolve directory indexes,
so the bare hostname is not the launcher URL. No additional Worker is required.
Preserve object MIME and cache headers, serve image byte ranges with HTTP 206
and correct `Content-Range`, and disable content transformation/compression.
Use one HTTPS origin; redirects to another asset origin are rejected by
publication checks. Immutable release objects use
`Cache-Control: public, max-age=31536000, immutable, no-transform`; the root redirect uses
`Cache-Control: no-cache, no-transform`. The `no-transform` directive prevents
Cloudflare's JavaScript Detections from injecting scripts into the HTML and
breaking exact-byte verification. JavaScript and WASM must retain their proper
MIME types. No cross-origin-isolation headers are required by the single-CPU path.

Publication uploads the built payload under `releases/<commit>/`, records
release metadata, and uploads `manifest.json` last. Existing objects are reused
only if identical. Remote headers, manifest and image ranges are checked before
the root pointer changes. The promoted default URL is then checked over HTTP for
the expected pointer bytes and serving headers.

Public HTTP checks identify themselves as `nix-config-emulator-publisher`.
Cloudflare on this hostname rejects the generic `Python-urllib` User-Agent
with HTTP 403. HTTP failures report the method, relative object path and
status code, without dumping endpoint URLs, response bodies or credentials.

On failed post-promotion HTTP verification, the workflow conditionally restores the previous
pointer. If no prior pointer exists, it conditionally replaces its own failed
redirect with a plain-text unavailable response rather than an unsafe deletion.
Both paths use the current ETag and leave a concurrent replacement untouched.
The unavailable response is not a successful deployment; CI still fails.
Previous releases are retained. For manual rollback, retrieve `previous-index.html` and
`previous-index-metadata.json` from the publication evidence, read the current
root object's ETag, then conditionally PUT the saved body with its original
serving metadata using `If-Match` for that ETag. Check the default URL's bytes and
serving headers, then manually open the restored release in a compatible browser.
Do not delete release objects. A hard runner termination can prevent automatic
rollback; retained evidence supports operator recovery. Guest boot failures found
manually do not trigger automatic rollback.

Missing configuration fails explicitly before storage access. Live R2 probes
have verified HTTPS delivery, byte ranges and unmodified HTML with the cache
policies above. Complete S3 promotion/rollback and manual deployed-guest verification
remain pending; successful HTTP delivery alone does not prove that the guest boots.

## Secrets

Encrypted with sops + age. Three secret files: `hosts/framework/secrets.yaml`, `hosts/homelab/secrets.yaml`, `home/om/secrets.yaml`. Each encrypted for the host age key and the user age key per `.sops.yaml`.
