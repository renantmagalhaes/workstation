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
