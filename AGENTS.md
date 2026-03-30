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

## Gotchas and Non-Obvious Patterns

- **Multiple build systems**: Different subdirectories use different build systems (Stack for Haskell, Cargo/devenv for Rust, flakes for NixOS).
- **Symlinking via home-manager**: Most configs are not directly edited in their system locations - edit in this repo, apply via `nixos-rebuild switch`.
- **NixOS secrets**: Secrets are encrypted with SOPS. Don't manually edit `secrets/secrets.yaml` - use `sops` command.
- **Per-system overlays**: Some systems (like kite with NVIDIA) may need different package versions. Check `overlays/` and per-system configs.
- **Scripts in ~/bin**: These are managed by home-manager. Adding/removing scripts requires home-manager switch.
- **macOS differences**: Different username (`thomas.peiselt` vs `pi`), different home directory, different configs via `nix-darwin`.
- **Fish script naming**: `,` prefix indicates quick utilities. Don't assume all scripts start with `,`.
- **Server detection**: `isServer` flag in home-manager determines which modules to load (mail, backup, etc.). Check `tiny` is the main server.
- **direnv usage**: Many subdirectories have `.envrc` or `.direnv/`. Make sure direnv is enabled and `.envrc` is allowed (`direnv allow`).
- **Neovim plugin lockfile**: `lazy-lock.json` is in `.gitignore`. Plugin versions are not pinned by default.

## Configurations (`configs/`)

### Overview
Application-specific configurations in `configs/`. These are managed by home-manager and symlinked to appropriate locations.

### Key Configurations

- **xbindkeys** - `configs/xbindkeys/rc` → `~/.xbindkeysrc`
- **unison** - `configs/unison/` → `~/.unison/`
  - `common` - Common settings
  - `default.prf` - Default profile
  - `tiny_local.prf`, `tinyx.prf` - Specific profiles
- **surfingkeys/** - Browser keybinding config

