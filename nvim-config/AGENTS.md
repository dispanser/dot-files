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
