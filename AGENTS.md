# AGENTS.md

This repository contains personal dot-files for NixOS, macOS, and various development tools. It's a multi-project repository with different build systems and workflows.

## Repository Structure

This is a **multi-project dot-files repository** organized into several subdirectories, each with its own purpose and build system:

- **`nixos-systems/`** - NixOS system configurations (flakes + home-manager)
- **`xmonad-config/`** - Haskell xmonad window manager config (Stack project)
- **`nvim-config/`** - Neovim configuration (lazy.nvim)
- **`configs/`** - Various application configs (zellij, obsidian, unison, etc.) - not managed by nix or home-manager.
- **`scripts/`** - Fish/shell scripts (symlinked to `~/bin/`)
- **`kanata/`** - Keyboard layout configurations
- **`darwin-scripts/`** - macOS-specific scripts

---

## NixOS Systems (`nixos-systems/`)

### Overview
NixOS configurations for multiple machines using flakes and home-manager. Each system has its own configuration file (e.g., `kite.nix`, `oxide.nix`, `tiny.nix`).

### Systems
- **kite** - Desktop with NVIDIA GPU (Big Boy)
- **chatham** - Laptop (Trackbar)
- **tiny** - Mini server
- **oxide** - X12 Gen 2 laptop
- **x12** - X12 laptop
- **x1t3** - ThinkPad X1 Tablet Gen 3
- **voyager** - Legion Go handheld

### Essential Commands

**Build and apply configuration to a system:**
```bash
cd nixos-systems
sudo nixos-rebuild switch --flake .#<hostname>
```

**Test changes without applying:**
```bash
sudo nixos-rebuild test --flake .#<hostname>
```

**Build only (no apply):**
```bash
sudo nixos-rebuild build --flake .#<hostname>
```

**Build on a mounted target (new system setup):**
```bash
sudo nixos-install --flake /mnt/home/pi/src/github/dispanser/dot-files/nixos-systems/#<hostname>
```

**Update flake inputs:**
```bash
cd nixos-systems
nix flake update
```

### Setting up a New System

See `nixos-systems/readme.md` for detailed instructions. Key steps:

1. Create a new system file (e.g., `newhost.nix`) by copying an existing one
2. Edit `nixos-systems/flake.nix` to add the new system to `nixosConfigurations`
3. Follow the disk setup and mounting procedure in the readme
4. Run `sudo nixos-install` with the flake path

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

```bash
# Generate age key from SSH
nix-shell --run fish -p ssh-to-age age
ssh-to-age -private-key -i ~/.ssh/unison_tiny > ~/.config/sops/age/keys.txt

# Edit secrets
cd nixos-systems
sops secrets/secrets.yaml
```

Key generation per host is planned (currently uses host names in `.sops.yaml`).

### Overlays

Custom package overlays defined in `nixos-systems/overlays/`:
- **llama-cpp** - Custom build with CUDA/ROCm support
- **touchscreen-gestures** - Local path input
- Various GPU and build flag overrides

### Patterns and Conventions

- Use `lib.mkIf` for conditional logic (Linux vs Darwin, server vs desktop)
- Import base configurations in system-specific files
- Use `specialArgs` when passing inputs to modules
- System hostnames match configuration filenames
- Home modules in `home/` are imported based on `isServer` flag

---

## XMonad Configuration (`xmonad-config/`)

### Overview
Haskell xmonad configuration as a complete Stack project for LSP support. Located in `~/.xmonad/` via symlinks.

### Setup

**Link configuration to ~/.xmonad:**
```bash
./link.sh
```

This creates symlinks:
- `~/.xmonad/xmonad.hs` → `xmonad-config/xmonad/xmonad.hs`
- `~/.xmonad/lib` → `xmonad-config/src`

### Build Commands

**Enter dev environment (Nix devshell):**
```bash
cd xmonad-config
nix develop
# or
direnv allow  # if direnv is enabled
```

**Build with Stack:**
```bash
cd xmonad-config
stack build
```

**Install xmonad:**
```bash
stack install
# xmonad gets installed to ~/.local/bin/
```

**Test xmonad configuration:**
```bash
xmonad --recompile
# then restart xmonad with Mod+q
```

### Project Structure

- `flake.nix` - Devshell configuration
- `package.yaml` - Hpack configuration (defines library and executables)
- `devshell.toml` - Devshell packages (stack)
- `stack.yaml` - Stack resolver (lts-18.25)
- `xmonad/xmonad.hs` - Main xmonad configuration
- `src/` - Library source (custom modules)
  - `PiMonad/Workspaces.hs` - Dynamic project workspace management
  - `PiMonad/Scratches.hs` - Scratchpad management
  - `XMonad/Actions/` - Custom XMonad actions
  - `Debug/Debug.hs` - Debug utilities

### Key XMonad Features

- **Dynamic Projects** - Project-based workspace management
- **Scratchpads** - Custom scratchpad system (not NamedScratchpad)
- **Layouts** - ResizableTile, Accordion, Tabbed with decoration
- **Multi-toggle** - Layout toggles
- **FloatSnap** - Window snapping and resizing
- **GridSelect** - Window/program selection
- **Custom Keybindings** - Extensive keybinding system with submaps

### Testing XMonad Changes

1. Recompile: `xmonad --recompile`
2. Restart xmonad: `Mod+q` (default)
3. Check logs in `~/.xmonad/xmonad.errors` if issues

### Dependencies

- XMonad and xmonad-contrib
- Containers library
- X11 libraries (via Nix packages in stack.yaml)
- GHC 8.10.7 (via LTS-18.25)

---

## Neovim Configuration (`nvim-config/`)

### Overview
Neovim configuration using **lazy.nvim** plugin manager. Modular Lua structure.

### Setup

**Initial setup (if not already done):**
```bash
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git ~/.local/nvim/lazy/lazy.nvim
```

Configuration is managed via home-manager: `nixos-systems/home/home.nix` symlinks `~/.config/nvim` to `nvim-config/`.

### Structure

```
nvim-config/
├── init.lua          - Entry point (requires "pi")
├── lua/pi/           - Main configuration namespace
│   ├── init.lua      - Main initialization
│   ├── settings.lua  - General settings
│   ├── remap.lua     - Keybindings
│   ├── lazy.lua      - Lazy.nvim configuration
│   ├── notes.lua     - Notes functionality
│   └── harpoon.lua   - Harpoon plugin config
├── lua/plugins/      - Plugin configurations
│   ├── init.lua      - Plugin list
│   ├── lsp.lua       - LSP setup
│   ├── treesitter.lua - Treesitter
│   ├── telescope.lua - Telescope
│   ├── rust.lua      - Rust-specific plugins
│   └── ...
└── after/            - After plugin loads
    ├── plugin/       - Plugin-specific configs
    └── ftplugin/     - Filetype-specific configs
```

### Key Settings

- **Editor**: `nvim`
- **Indentation**: 2 spaces (softtabstop=2, tabstop=2, shiftwidth=2)
- **Line numbers**: Relative + absolute
- **Leader key**: `<Space>`
- **No swap files** (uses undofile instead)
- **Foldmethod**: Treesitter-based (set via `<leader>fmt`)

### Keybindings (Leader-based)

- File ops: `<leader>fs` (save), `<leader>fq` (save+quit), `<leader>qq` (quit all)
- Buffer: `<leader>bd` (close), `]b`/`[b` (next/prev)
- Jump between buffers: `<leader><Tab>`
- Enter normal mode: `jk` in insert mode
- Fold levels: `z0`-`z3`, `z<Space>` for level 0

### Plugin Management

All plugins managed through **lazy.nvim** in `lua/pi/lazy.lua`. To update plugins:

- Within Neovim: `:Lazy update`
- To sync/install new plugins: `:Lazy sync`

### Language-Specific Configs

- **Rust** - Extra config in `after/ftplugin/rust.lua`
- Custom snippets in `snippets/rust.snippets`

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

## Configurations (`configs/`)

### Overview
Application-specific configurations in `configs/`. These are managed by home-manager and symlinked to appropriate locations.

### Key Configurations

- **xbindkeys** - `configs/xbindkeys/rc` → `~/.xbindkeysrc`
- **unison** - `configs/unison/` → `~/.unison/`
  - `common` - Common settings
  - `default.prf` - Default profile
  - `tiny_local.prf`, `tinyx.prf` - Specific profiles
- **zellij** - `configs/zellij/config.kdl` - Terminal multiplexer config
- **psql** - `configs/psql/.psqlrc` → `~/.psqlrc`
- **obsidian/** - Obsidian vault configuration with plugins
- **surfingkeys/** - Browser keybinding config
- **intellij/** - IntelliJ IDEA settings and `.ideavimrc`
- **keyboards/** - Keyboard layout files

### File Management

Configs are symlinked via `home.file` in `nixos-systems/home/home.nix`:
```nix
home.file = {
  "bin" = { source = ../../scripts; recursive = true; };
  "bin/darwin" = { source = ../../darwin-scripts; recursive = true; };
  ".xbindkeysrc" = { source = ../../configs/xbindkeys/rc; };
  ".unison" = { source = ../../configs/unison; recursive = true; };
  # ... etc
};
```

---

## Kanata Keyboard Configs

### Overview
Kanata keyboard layout configurations for custom keyboards.

### Files

- `kanata/piantor_thinkpad.kbd` - Kanata layout for ThinkPad with Piantor keyboard
- `kanata/piantor_thinkpad_macos.kbd` - macOS variant

These are for advanced keyboard remapping using Kanata.

---

## Nix Darwin (`nix-darwin/`)

### Overview
Darwin/macOS system configuration using nix-darwin (separate from home-manager on macOS).

### Structure

- `flake.nix` - Darwin flake configuration
- `darwin.nix` - Main Darwin config
- `kanata.nix` - Kanata service config
- `readme.md` - Setup instructions

---

## Git Workflow

### Repository
This is a **private dot-files repository** located at `/home/pi/src/github/dispanser/dot-files/`.

### Common Patterns

- Track all personal configuration changes in git
- Use fish as primary shell
- Use neovim as primary editor
- NixOS systems managed via flakes
- Secrets encrypted with SOPS (age)

### Ignore Patterns

See `.gitignore`:
- `nvim-config/lazy-lock.json` - Plugin lockfile (optional to track)
- `.aider*` - AI assistant files

---

## Cross-Cutting Concerns

### User Information

- **Username on Linux**: `pi`
- **Username on macOS**: `thomas.peiselt`
- **Home directory**: `/home/pi` (Linux) or `/Users/thomas.peiselt` (macOS)

### Development Tools

- **Editor**: Neovim
- **Shell**: Fish (with bash/zsh completions enabled)
- **Terminal**: Alacritty or Kitty
- **Window Manager**: xmonad (Linux)
- **Version Control**: Git

### Nix-Related Tools

- **direnv** + **nix-direnv** - Automatic dev shell activation
- **flake-utils** - Flake utilities (used in xmonad-config)
- **home-manager** - User-space package and config management
- **nix-ld** - Run unpatched binaries on NixOS

### Backup and Sync

- **unison** - File synchronization (especially with tiny server)
- **restic** - Backup tool

### Hardware-Specific Configs

- **NVIDIA**: Kite system has NVIDIA GPU
- **Touch**: Touch devices, touchscreens managed via custom modules
- **Keyboard**: Multiple keyboard configs (Vial, Kanata, TrackPoint)
- **Audio**: Audio hooks in xidlehook

---

## Quick Reference

### NixOS System Management
```bash
# Apply system changes
sudo nixos-rebuild switch --flake nixos-systems/#<hostname>

# Update flake inputs
cd nixos-systems && nix flake update

# Edit secrets
cd nixos-systems && sops secrets/secrets.yaml
```

### XMonad Development
```bash
# Build
cd xmonad-config && stack build

# Recompile after changes
xmonad --recompile

# Restart
Mod+q
```

### Neovim
```bash
# Update plugins
nvim  # then :Lazy update

# Open Neovim
nvim  # or <leader> keybindings
```

---

## Gotchas and Non-Obvious Patterns

1. **Multiple build systems**: Different subdirectories use different build systems (Stack for Haskell, Cargo/devenv for Rust, flakes for NixOS).

2. **Symlinking via home-manager**: Most configs are not directly edited in their system locations - edit in this repo, apply via `home-manager switch` or `nixos-rebuild switch`.

3. **NixOS secrets**: Secrets are encrypted with SOPS. Don't manually edit `secrets/secrets.yaml` - use `sops` command.

4. **Per-system overlays**: Some systems (like kite with NVIDIA) may need different package versions. Check `overlays/` and per-system configs.

5. **xmonad symlinks**: Edit files in `xmonad-config/`, not `~/.xmonad/`. Use `link.sh` to recreate symlinks if needed.

6. **Scripts in ~/bin**: These are managed by home-manager. Adding/removing scripts requires home-manager switch.

7. **macOS differences**: Different username (`thomas.peiselt` vs `pi`), different home directory, different configs via `nix-darwin`.

8. **Fish script naming**: `,` prefix indicates quick utilities. Don't assume all scripts start with `,`.

9. **Server detection**: `isServer` flag in home-manager determines which modules to load (mail, backup, etc.). Check `tiny` is the main server.

10. **Custom Nixpkgs overlays**: The `llama-cpp` build has specific GPU flags. Changes here affect multiple systems.

11. **xmonad Stack resolver**: Uses LTS-18.25 with specific X11 packages. Don't update stack without checking compatibility.

12. **direnv usage**: Many subdirectories have `.envrc` or `.direnv/`. Make sure direnv is enabled and `.envrc` is allowed (`direnv allow`).

13. **New system setup**: The `nixos-systems/readme.md` contains incomplete setup notes. Always verify steps and add missing information.

14. **Keyboard configs**: Multiple keyboard systems (Kanata, Vial, xbindkeys). Check which one applies to your hardware.

15. **Neovim plugin lockfile**: `lazy-lock.json` is in `.gitignore`. Plugin versions are not pinned by default.
