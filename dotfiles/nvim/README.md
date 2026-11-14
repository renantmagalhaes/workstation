# Custom Neovim IDE Distribution

A fast, robust, low-maintenance Neovim configuration built for day-to-day software engineering without the instability and maintenance overhead of external distribution frameworks.

## ✨ Philosophy
- **Zero Bloat & Maintenance**: No upstream distribution framework overrides; no surprise auto-updates breaking your setup.
- **Pure `lazy.nvim`**: Automatic background update checker is disabled (`checker.enabled = false`) for deterministic stability.
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

### Search & Navigation
| Keymap | Action |
| --- | --- |
| <kbd>Space</kbd> <kbd>Space</kbd> | Fuzzy search files across the entire folder / project |
| <kbd>Ctrl+f</kbd> or `<leader>f` | Fuzzy search inline (current buffer) |
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
- **Theme**: Cyberdream (transparent background, terminal colors, italic comments)
- **File Explorer**: `nvim-tree` with Devicons & Git indicators
- **Fuzzy Finder**: `telescope.nvim`
- **LSP**: `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim`
- **Linting**: `nvim-lint` (auto-detects filetype on save / buffer enter)
- **Formatting**: `conform.nvim` (format-on-save + Pretty JSON)
- **Syntax Highlighting**: `nvim-treesitter` (with `auto_install = true`)
- **Autocompletion**: `nvim-cmp` (LSP, path autocomplete, snippets, buffer)
- **Git**: `gitsigns.nvim`, `lazygit.nvim`, `vim-fugitive`
- **CSV Support**: `rainbow_csv.nvim` (colored columns & column alignment)
- **Markdown**: `render-markdown.nvim` (rich inline rendering) + `markdown-preview.nvim` + `img-clip.nvim`
- **Tabs & Statusline**: `bufferline.nvim` + `lualine.nvim`
- **Editor Ergonomics**: `nvim-autopairs`, `Comment.nvim`, `nvim-surround`, `colorizer`, `rainbow-delimiters`, `which-key`

---

## 🚀 Installation & Update
Run the installation script:
```bash
./scripts/vim.sh
```
