# Custom Neovim IDE Distribution

A fast, robust, low-maintenance Neovim configuration built for day-to-day software engineering without the instability and maintenance overhead of external distribution frameworks.

## ✨ Philosophy
- **Zero Bloat & Maintenance**: No upstream distribution framework overrides; no surprise auto-updates breaking your setup.
- **Pure `lazy.nvim`**: Automatic background update checker is disabled (`checker.enabled = false`) for deterministic stability.
- **Modern & Appealing Visuals**: Pill/capsule statusline, breadcrumbs bar, animated cursor trails, floating rounded inputs, and toast notifications matching Cyberdream.
- **VS Code Ergonomics**: Familiar keybindings (<kbd>Ctrl+s</kbd> to save, <kbd>Ctrl+d</kbd> to quit with prompt, <kbd>Ctrl+b</kbd> sidebar, <kbd>Ctrl+f</kbd> buffer find, tabs, indent guides).

---

## ⌨️ Keybindings Quick Reference

### General & File Operations
| Keymap | Action |
| --- | --- |
| <kbd>Ctrl+s</kbd> | Save file (Normal, Insert, Visual) |
| <kbd>Ctrl+d</kbd> | Exit Neovim (**prompts to save** if unsaved changes exist) |
| <kbd>Ctrl+a</kbd> | Select all text in buffer |
| <kbd>U</kbd> | Redo |
| <kbd>Alt+j</kbd> / <kbd>Alt+k</kbd> | Move selected block down / up (Visual mode) |
| <kbd>Tab</kbd> / <kbd>Shift+Tab</kbd> | Indent / Outdent selected lines (Visual mode) |
| <kbd>Ctrl+c</kbd> / <kbd>Ctrl+v</kbd> | Copy to system clipboard / Paste from system clipboard |
| <kbd>j</kbd><kbd>k</kbd> or <kbd>k</kbd><kbd>j</kbd> | Quick exit from Insert mode to Normal mode |

### Search & Navigation
| Keymap | Action |
| --- | --- |
| <kbd>Space</kbd> <kbd>Space</kbd> | Fuzzy search files across the entire folder / project |
| <kbd>Ctrl+f</kbd> or `<leader>f` | Fuzzy search inline (current buffer) |
| <kbd>s</kbd> | **Flash Jump**: Jump anywhere on the screen in 2 keystrokes |
| `<leader>fg` or `<leader>/` | Live grep text across the whole project |
| `<leader>fb` | List and search open buffers |
| `<leader>fr` | Search recent files |

### Find & Replace
| Keymap | Action |
| --- | --- |
| `<leader>sr` | **Project Find & Replace** (`grug-far`): VS Code-style find & replace with live diff |
| `<leader>sf` | **File Find & Replace** (`grug-far`): Find & replace within current file |
| `<leader>sw` | **Word Find & Replace** (`grug-far`): Find & replace word under cursor |
| `<leader>R` or `<leader>mr` | **Interactive Multi-Replace** (`muren`): Side-by-side regex buffer replace |

### Lateral Tree & Explorer
| Keymap | Action |
| --- | --- |
| `<leader>e` or <kbd>Ctrl+b</kbd> | Toggle lateral file tree |
| `<leader>o` | Reveal current file in file tree |

### Tools & Programming
| Keymap | Action |
| --- | --- |
| `<leader>pj` | **Pretty JSON**: Formats JSON buffer with `jq` / Python / LSP |
| `<leader>cf` or `<leader>fm` | Format document (via `conform.nvim` / LSP) |
| `<leader>gg` or `<leader>lg` | Open **LazyGit** floating window |
| `<leader>p` or `<leader>P` | **Paste image** from clipboard into Markdown (auto-saved to `assets/images/`) |
| `<leader>mp` | Toggle Markdown browser preview |
| `<leader>xx` | Toggle Trouble diagnostics panel |
| `[b` / `]b` | Previous / Next buffer tab |
| `<leader>1`..`<leader>9` | Jump directly to buffer tab 1-9 |
| `<leader>bd` | Close current buffer |

### Git & Code Signs
| Keymap | Action |
| --- | --- |
| `]c` / `[c` | Jump to next / previous Git hunk |
| `<leader>hp` | Preview Git hunk diff inline |
| `<leader>hs` | Stage Git hunk |
| `<leader>gb` | Toggle Git line blame |

---

## 📦 Installed Features
- **Dashboard**: `alpha-nvim` (sleek minimalist startup dashboard with quick shortcuts)
- **Theme**: Cyberdream (transparent background, terminal colors, italic comments)
- **Statusline**: `lualine.nvim` (modern rounded capsule/pill separators ``/``)
- **Breadcrumbs**: `barbecue.nvim` + `nvim-navic` (shows file and code hierarchy)
- **Floating Dialogs**: `dressing.nvim` (rounded popups for rename, selection, and inputs)
- **Toast Notifications**: `nvim-notify` (smooth animated notifications)
- **Scrollbar**: `nvim-scrollbar` + `nvim-hlslens` (Git, diagnostic, and search count marks)
- **Navigation**: `flash.nvim` (<kbd>s</kbd> jump) + `better-escape.nvim` (<kbd>jk</kbd> exit)
- **Fluid Cursor**: `smear-cursor.nvim` (smooth cursor animations between lines and windows)
- **File Explorer**: `nvim-tree` with Devicons & Git indicators
- **Fuzzy Finder**: `telescope.nvim`
- **Find & Replace**: `MagicDuck/grug-far.nvim` (project-wide find & replace with live diff) + `AckslD/muren.nvim` (interactive multi-line regex replace)
- **LSP**: On-demand auto-installer and launcher per filetype
- **Linting**: `nvim-lint` (auto-detects filetype on save / buffer enter without crashes)
- **Formatting**: `conform.nvim` (format-on-save + Pretty JSON)
- **Syntax Highlighting**: `nvim-treesitter` (pinned to modern `main` branch for Neovim 0.12+)
- **Autocompletion**: `nvim-cmp` (LSP, path autocomplete, snippets, buffer)
- **Git**: `gitsigns.nvim`, `lazygit.nvim`, `vim-fugitive`
- **CSV Support**: `rainbow_csv.nvim` (colored columns & column alignment)
- **Markdown**: `render-markdown.nvim` (rich inline rendering) + `markdown-preview.nvim` + `img-clip.nvim`
- **Tabs**: `bufferline.nvim` (VS Code style top tabs)
- **Editor Ergonomics**: `nvim-autopairs`, `Comment.nvim`, `nvim-surround`, `colorizer`, `rainbow-delimiters`, `which-key`

---

## 🚀 Installation & Update
Run the installation script:
```bash
bash scripts/vim.sh
```

---

## 🔒 Security & Deterministic Lockfile (`lazy-lock.json`)

To prevent supply-chain attacks, regressions, or breaking changes from upstream plugin repositories, this distribution uses a **cryptographic lockfile** (`dotfiles/nvim/lazy-lock.json`).

- **Immutable Commit SHAs**: Every single plugin is pinned to an audited git commit hash.
- **Zero Surprise Updates**: Background update checks and automatic fetching are completely disabled (`checker.enabled = false`).
- **Safe Re-installation**: Running `bash scripts/vim.sh` executes `+Lazy! restore`, ensuring that every plugin is checked out to the exact commit pinned in `lazy-lock.json`.

---

## 🛠️ Future Maintenance Workflow

- **Deliberately updating plugins**:
  1. Open Neovim and run `:Lazy update <plugin-name>` (or `:Lazy update` for all plugins).
  2. Test your workflow to verify stability and ensure no breaking changes or syntax errors.
  3. Commit the updated `dotfiles/nvim/lazy-lock.json` to git:
     ```bash
     git add dotfiles/nvim/lazy-lock.json
     git commit -m "chore(nvim): update plugin lockfile"
     ```

- **Rolling back or restoring state**:
  If a test or manual change breaks your setup, instantly revert all plugins back to the locked commit SHAs:
  ```bash
  nvim --headless "+Lazy! restore" +qa
  ```

- **Adding a new plugin**:
  1. Add its specification to a file in `dotfiles/nvim/lua/plugins/`.
  2. Open Neovim; `lazy.nvim` will automatically install it and record its exact commit SHA into `lazy-lock.json`.
  3. Backup the new plugin to your GitHub organization:
     ```bash
     python3 dotfiles/nvim/scripts/fork_plugins.py
     ```
  4. Stage and commit your lua spec, `lazy-lock.json`, and any configuration updates.

- **Syncing / Forking All Plugins to Backup Org**:
  Use the built-in backup script to automatically fork any new plugins to [rtm0x00](https://github.com/rtm0x00):
  ```bash
  # Check status without making changes
  python3 dotfiles/nvim/scripts/fork_plugins.py --dry-run

  # Fork any newly added plugins (all branches included)
  python3 dotfiles/nvim/scripts/fork_plugins.py
  ```

- **Auditing installed plugins**:
  Open `dotfiles/nvim/lazy-lock.json` to inspect every pinned commit SHA and branch.
