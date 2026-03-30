## NixOS Systems

### Overview

NixOS configurations for multiple machines using flakes and home-manager. Each system has its own configuration file (e.g., `kite.nix`, `oxide.nix`, `tiny.nix`).

### Systems

- **kite** - Desktop with NVIDIA GPU (Big Boy)
- **chatham** - external SSD, supposed to boot into anything (recovery, turning any computer into my own)
- **tiny** - Mini server
- **oxide** - X12 Gen 2 laptop
- **x12** - X12 laptop
- **x1t3** - ThinkPad X1 Tablet Gen 3
- **voyager** - Legion Go handheld

### Essential Commands

**Test changes without applying:**
```bash
nixos-rebuild test --flake .#<hostname>
```

**Build only (no apply):**
```bash
nixos-rebuild build --flake .#<hostname>
```

**Update flake inputs:**
```bash
nix flake update <input> # input is optional
```

See `nixos-systems/readme.md` for detailed instructions on setting up a new system from scratch

### File Organization

- `flake.nix` - Main flake defining all systems and overlays
- `base.nix` - Base system configuration included by all systems
- `<hostname>.nix` - Per-system hardware/config
- `home/` - Home-manager configurations
  - `home.nix` - Main home-manager config
  - `packages.nix` - Package groups (desktopPkgs, develPkgs, etc.)
  - Individual configs: `alacritty.nix`, `fish.nix`, `git.nix`, etc.
- `overlays/` - Nixpkgs overlays
  - `default.nix` - Main overlays (llama-cpp, touchscreen-gestures)
- `secrets/secrets.yaml` - Encrypted secrets (managed by sops-nix)
- `.sops.yaml` - SOPS configuration for age-based encryption

### Secrets Management

Uses **sops-nix** with age encryption. To manage secrets:

### Patterns and Conventions

- Use `lib.mkIf` for conditional logic (Linux vs Darwin, server vs desktop)
- Import base configurations in system-specific files
- Use `specialArgs` when passing inputs to modules
- System hostnames match configuration filenames
- Home modules in `home/` are imported based on `isServer` flag

---


## Rust Project (`rs/`)

### Overview
Rust project using **devenv** for reproducible development environments.

### Build Commands

**Enter dev environment:**
```bash
cd rs
devenv shell
# or
direnv allow  # if direnv is enabled
```

**Build project:**
```bash
cargo build
```

**Run project:**
```bash
cargo run
```

**Run tests:**
```bash
cargo test
```

**Check without building:**
```bash
cargo check
```

### Structure

- `Cargo.toml` - Cargo manifest (edition 2024)
- `devenv.yaml` - Devenv configuration
- `devenv.nix` - Generated Nix environment
- `src/main.rs` - Main entry point (currently just "Hello, world!")
- `.envrc` - Direnv integration

### Dependencies

- `walkdir` - Directory traversal
- `md5` - MD5 hashing

### Tooling

Uses **devenv** for Nix-based development environment. No custom build scripts or Makefiles.

---

## Scripts

### Overview
Fish and shell scripts located in `scripts/` and `darwin-scripts/`. These are symlinked to `~/bin/` by home-manager.

### Script Prefix Convention
Scripts starting with `,` (comma) are executable utilities:
- `,n` - Quick nix-shell wrapper: `nix-shell -p <package> --run "<command>"`
- `,np` - Similar to `,n` with different argument handling
- `,rs.rs` - Cargo script for CLI argument parsing
- `,bedroom` - Bedroom-related script
- `,brightness` - Brightness control
- `,chathamount` - Chat history amount
- `,diffe` - Diff utility
- `,md2pdf` - Markdown to PDF
- `,md2remarkable` - Markdown to Remarkable tablet
- `,nix-root-mount.sh` - NixOS root mounting helper
- `,nix_clean` - Nix store cleanup
- `,parquet-test` - Parquet testing
- `,s_clean_known_hosts.fish` - Clean SSH known_hosts
- `,se` - Edit script
- `,st` - Time script
- `,umount-mnt.sh` - Unmount helper
- `,work-light` - Work lighting control

### Shell Types

- **Fish scripts** - Most scripts use Fish shebang `#!/usr/bin/env fish`
- **Cargo scripts** - Use `#!/usr/bin/env -S cargo -Zscript` for inline Rust scripts

### Script Locations

- `scripts/` - Linux scripts (symlinked to `~/bin/`)
- `darwin-scripts/` - macOS-specific scripts (symlinked to `~/bin/darwin/`)

---

---

## Kanata Keyboard Configs

### Overview

Kanata keyboard layout configurations for custom keyboards.

### Files

- `kanata/piantor_thinkpad.kbd` - Kanata layout for ThinkPad with Piantor keyboard
- `kanata/piantor_thinkpad_macos.kbd` - macOS variant

These are for advanced keyboard remapping using Kanata.

## Nix Darwin (`nix-darwin/`)

### Overview
Darwin/macOS system configuration using nix-darwin (separate from home-manager on macOS).

### Structure

- `flake.nix` - Darwin flake configuration
- `darwin.nix` - Main Darwin config
- `kanata.nix` - Kanata service config
- `readme.md` - Setup instructions

## Cross-Cutting Concerns

### User Information

- **Username on Linux**: `pi`
- **Username on macOS**: `thomas.peiselt`
- **Home directory**: `/home/pi` (Linux) or `/Users/thomas.peiselt` (macOS)

### Development Tools

- **Editor**: Neovim
- **Shell**: Fish (with bash/zsh completions enabled)
- **Terminal**: Alacritty or Kitty
- **Window Manager**: niri + noctalia shell

### Backup and Sync

- **unison** - File synchronization (especially with tiny server)
- **restic** - Backup tool

### Hardware-Specific Configs

- **NVIDIA**: Kite system has NVIDIA GPU
- **Touch**: Touch devices, touchscreens managed via custom modules
- **Keyboard**: Multiple keyboard configs (Vial, Kanata, TrackPoint)
- **Audio**: Audio hooks in xidlehook
