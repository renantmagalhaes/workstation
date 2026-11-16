# Custom Neovim IDE Distribution

A fast, robust, low-maintenance Neovim configuration built for day-to-day software engineering without the instability and maintenance overhead of external distribution frameworks.

## ✨ Philosophy
- **Zero Bloat & Maintenance**: No upstream distribution framework overrides; no surprise auto-updates breaking your setup.
- **Pure `lazy.nvim`**: Automatic background update checker is disabled (`checker.enabled = false`) for deterministic stability.
- **Modern & Appealing Visuals**: Pill/capsule statusline, breadcrumbs bar, animated cursor trails, floating rounded inputs, and toast notifications matching Cyberdream.
- **VS Code Ergonomics**: Familiar keybindings (<kbd>Ctrl+s</kbd> save, <kbd>Ctrl+p</kbd> quick open, <kbd>Ctrl+/</kbd> comment, <kbd>Alt+↑/↓</kbd> move line, <kbd>F2</kbd>/<kbd>F12</kbd> LSP, <kbd>F5</kbd>/<kbd>F9</kbd>/<kbd>F10</kbd>/<kbd>F11</kbd> debugging, <kbd>Ctrl+b</kbd> sidebar, <kbd>Ctrl+f</kbd> buffer find, <kbd>Ctrl+d</kbd> quit with prompt, tabs, indent guides).
- **Full IDE Loop**: Debugger, test explorer, code folding, inlay hints, go-to-symbol, side-by-side git diff and merge-conflict resolution — all inside the editor.

---

## ⌨️ Keybindings Quick Reference

### General & File Operations
| Keymap | Action |
| --- | --- |
| <kbd>Ctrl+s</kbd> | Save file (Normal, Insert, Visual) |
| <kbd>Ctrl+d</kbd> | Exit Neovim (shows centered modal dialog with `[Yes]` `[No]` `[Cancel]` buttons if unsaved changes exist) |
| <kbd>Ctrl+a</kbd> | Select all text in buffer |
| <kbd>U</kbd> | Redo |
| <kbd>Alt+↑</kbd> / <kbd>Alt+↓</kbd> (or <kbd>Alt+k</kbd> / <kbd>Alt+j</kbd>) | Move line / selection up / down (Normal, Insert, Visual) |
| <kbd>Ctrl+/</kbd> | Toggle line comment (Normal, Insert, Visual — selection is kept) |
| <kbd>Tab</kbd> / <kbd>Shift+Tab</kbd> | Indent / Outdent selected lines (Visual mode) |
| <kbd>Ctrl+c</kbd> / <kbd>Ctrl+v</kbd> | Copy selection (or current line in Insert mode) / Paste from system clipboard |
| <kbd>j</kbd><kbd>k</kbd> or <kbd>k</kbd><kbd>j</kbd> | Quick exit from Insert mode to Normal mode |

### Search & Navigation
| Keymap | Action |
| --- | --- |
| <kbd>:</kbd> | **Commandline Popup** (`noice.nvim`): Floating top-center command bar with live completions |
| `<leader>:` or `<leader>cp` | **Command Palette**: Fuzzy-search and run any Neovim command (VS Code `Ctrl+Shift+P` style) |
| `<leader>ch` | **Command History**: Search and re-run recent commands |
| <kbd>Ctrl+p</kbd> or <kbd>Space</kbd> <kbd>Space</kbd> | **Quick Open**: fuzzy search files across the entire folder / project |
| <kbd>Ctrl+f</kbd> or `<leader>fs` | Fuzzy search inline (current buffer) |
| <kbd>s</kbd> | **Flash Jump**: Jump anywhere on the screen in 2 keystrokes |
| `<leader>fg` or `<leader>/` | Live grep text across the whole project |
| `<leader>fb` | List and search open buffers |
| `<leader>fr` | Search recent files |

### Multi-Cursor & Multi-Line Editing (VS Code Style)
| Keymap | Action |
| --- | --- |
| Visual <kbd>I</kbd> | **Multi-line Insert**: Highlight lines and insert simultaneously at the beginning of all lines |
| Visual <kbd>A</kbd> | **Multi-line Append**: Highlight lines and append simultaneously at the end of all lines |
| Visual `<leader>m` | **Convert Selection**: Converts all selected lines into independent active cursors |
| <kbd>Ctrl+Alt+Down</kbd>, <kbd>Ctrl+Down</kbd> or `<leader>j` | Add a cursor on the line below |
| <kbd>Ctrl+Alt+Up</kbd>, <kbd>Ctrl+Up</kbd> or `<leader>k` | Add a cursor on the line above |
| <kbd>Ctrl+n</kbd> or <kbd>Alt+d</kbd> | **Match Next Word**: Add cursor at next occurrence of word under cursor (VS Code `Ctrl+D`) |
| `<leader>M` | Skip current match and jump to next occurrence |
| `<leader>A` | **Match All Occurrences**: Add cursors to all occurrences of word across file (VS Code `Ctrl+Shift+L`) |
| <kbd>Ctrl+Click</kbd> | **Mouse Multi-Cursor**: Click anywhere to place or remove a cursor |
| <kbd>Esc</kbd> | **Clear Cursors**: Exit multi-cursor mode and return to normal single cursor |

### Code Intelligence (LSP)
| Keymap | Action |
| --- | --- |
| <kbd>F12</kbd> or `gd` | Go to Definition (without a language server: Vim's local `gd`) |
| <kbd>Shift+F12</kbd> or `gr` | Find All References |
| <kbd>Ctrl+F12</kbd> or `gi` | Go to Implementation |
| <kbd>F2</kbd> or `<leader>rn` | Rename Symbol (F2 without a language server: rename the word everywhere in the file) |
| `<leader>ca` | Code Action (VS Code <kbd>Ctrl+.</kbd>) |
| <kbd>K</kbd> | Hover documentation |
| `[d` / `]d` | Previous / Next diagnostic (opens the diagnostic popup) |
| `<leader>d` | Line diagnostics popup |
| `<leader>fo` | Go to Symbol in file (VS Code <kbd>Ctrl+Shift+O</kbd>) |
| `<leader>fw` | Go to Symbol in workspace (VS Code <kbd>Ctrl+T</kbd>) |
| `<leader>uh` | Toggle inlay hints (inline types / parameter names; on by default where the server supports them — Lua, Go, TS/JS. Python's `pyright` does not send them) |

> Neovim 0.11's built-in `grr`/`grn`/`gra`/`gri`/`grt`/`grx` maps are removed so `gr` fires instantly.

### Code Folding
Syntax-aware folds (tree-sitter), all open when a file loads. A `▾` / `▸` marker next to the line number shows where a fold starts — click it to toggle.

| Keymap | Action |
| --- | --- |
| `za` | Toggle fold under cursor |
| `zc` / `zo` | Close / open fold |
| `zM` / `zR` | Fold / unfold everything |

### Debugging (VS Code Run & Debug)
`nvim-dap` + `nvim-dap-ui`. Python (debugpy), Go (delve) and JavaScript/TypeScript on Node (vscode-js-debug) work out of the box. The debug panels (variables, watches, call stack, breakpoints, console) open when a session starts and close when it ends, and variable values are shown inline while stepping.

- **Adapters**: installed in the background through Mason the first time the debugger loads (first <kbd>F5</kbd> / <kbd>F9</kbd>); a notification confirms when each one is ready.
- **Launch configs**: <kbd>F5</kbd> offers the built-in configs per language (e.g. *Launch file*, *Debug test*, *Attach*). A project's `.vscode/launch.json` is read automatically, so existing VS Code configs work as-is.
- **Python**: the program runs with the project's interpreter (`$VIRTUAL_ENV`, `./venv` or `./.venv`), like VS Code's interpreter picker.
- **TypeScript**: *Launch current file* runs it with `node`, so plain `.ts` needs a Node version that runs TypeScript or a `launch.json` (e.g. using `tsx`).

| Keymap | Action |
| --- | --- |
| <kbd>F5</kbd> or `<leader>Dc` | Start / Continue |
| <kbd>Shift+F5</kbd> or `<leader>Dt` | Stop |
| <kbd>Ctrl+Shift+F5</kbd> or `<leader>Dr` | Restart |
| <kbd>F9</kbd> or `<leader>Db` | Toggle breakpoint |
| `<leader>DB` / `<leader>Dl` | Conditional breakpoint / Logpoint |
| <kbd>F10</kbd> or `<leader>Do` | Step over |
| <kbd>F11</kbd> or `<leader>Di` | Step into (Windows Terminal uses F11 for fullscreen — use `<leader>Di` or unbind it there) |
| <kbd>Shift+F11</kbd> or `<leader>DO` | Step out |
| `<leader>DC` | Run to cursor |
| `<leader>De` | Evaluate expression under cursor / selection |
| `<leader>Du` / `<leader>DR` | Toggle debug panels / debug console (REPL) |
| `<leader>DX` | Clear all breakpoints |

### Testing (VS Code Test Explorer)
`neotest` with pytest, `go test`, jest and vitest adapters. Results show as ✓/✗ in the gutter, and the test explorer opens in the left sidebar like VS Code's Testing view. The test framework itself (e.g. `pytest`, `jest`) must be installed in the project.

| Keymap | Action |
| --- | --- |
| `<leader>tr` | Run nearest test |
| `<leader>tf` / `<leader>ta` | Run tests in file / all tests |
| `<leader>tl` | Re-run last test |
| `<leader>td` | Debug nearest test (uses the debugger above) |
| `<leader>ts` | Toggle test explorer panel |
| `<leader>to` / `<leader>tO` | Show test output / toggle output panel |
| `<leader>tw` | Watch file (re-run on save) |
| `<leader>tS` | Stop running tests |
| `]T` / `[T` | Next / previous failed test |

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
| <kbd>F2</kbd> (in the tree) | Rename file / folder under the cursor (same as `r`, like the VS Code explorer) |

### Tools & Programming
| Keymap | Action |
| --- | --- |
| `<leader>;` or `<leader>a` | **Toggle Dashboard**: Open startup dashboard from any file (press again to return) |
| `:Dashboard` or `:Alpha` | Command to open startup dashboard |
| <kbd>Ctrl+\</kbd> or `<leader>tt` | **Floating Terminal**: Quick popup terminal (stand-in for VS Code <kbd>Ctrl+`</kbd>, which most terminals can't send). <kbd>Esc</kbd><kbd>Esc</kbd> inside it enters Normal mode |
| `<leader>pj` | **Pretty JSON**: Formats JSON buffer with `jq` / Python / LSP |
| `<leader>cf` or `<leader>fm` | Format document (via `conform.nvim` / LSP) |
| `<leader>gg` or `<leader>lg` | Open **LazyGit** floating window |
| `]t` / `[t` | Next / Previous **TODO / FIX / NOTE** comment |
| `<leader>st` | Search all project **TODOs** with Telescope |
| `<leader>xt` | List all project **TODOs** in Trouble panel |
| `[x` | Jump up to enclosing function / class context (**Sticky Scroll**) |
| `<leader>ut` | Toggle Sticky Scroll header on/off |
| `<leader>mm` or `<leader>um` | **Toggle Minimap**: Show/hide right-side code minimap (`:MinimapToggle`) |
| `<leader>mf` | **Focus Minimap**: Browse inside the preview bar (<kbd>Enter</kbd> to jump, <kbd>Esc</kbd> to return) |
| `<leader>qs` | **Restore Session** for current folder |
| `<leader>ql` | **Restore Last Session** |
| `<leader>p` or `<leader>P` | **Paste image** from clipboard (Markdown / text buffers only; auto-saved to `assets/images/`) |
| `<leader>mp` | Toggle Markdown browser preview |
| `<leader>xx` | Toggle Trouble diagnostics panel |
| `[b` / `]b` | Previous / Next buffer tab |
| `<leader>1`..`<leader>9` | Jump directly to buffer tab 1-9 |
| `<leader>bd` | Close current buffer (keeps the window layout) |

### Git & Code Signs
| Keymap | Action |
| --- | --- |
| `<leader>go` or `:GitBrowse` | **Open in Git Web**: Opens current file/line (or Visual selection) on GitHub/GitLab |
| `<leader>gy` or `:GitCopyUrl` | **Copy Git Web URL**: Copies the web link to clipboard with line numbers |
| `:GBrowse` | Alias for `:GitBrowse` |
| `<leader>gg` or `<leader>lg` | Open **LazyGit** floating window |
| `]c` / `[c` | Jump to next / previous Git hunk |
| `<leader>hp` | Preview Git hunk diff inline |
| `<leader>hs` | Stage Git hunk |
| `<leader>gb` | Toggle Git line blame |
| `<leader>gd` | Toggle **Diff View**: side-by-side diff of all changes (`diffview.nvim`; also a 3-way merge view during merges) |
| `<leader>gf` / `<leader>gF` | **File history** of current file / whole repo |
| `co` / `ct` / `cb` / `c0` | **Merge conflict**: accept Current / Incoming / Both / None (only in files with conflict markers; Neovim must be opened at the repo root) |
| `]n` / `[n` | Next / previous merge conflict |

### ⚠️ Terminal & Keyboard Notes
A terminal can't send every key combination VS Code uses. What to know:

- **Ctrl+Shift+letter** (e.g. <kbd>Ctrl+Shift+F</kbd>, <kbd>Ctrl+Shift+O</kbd>) arrives as plain <kbd>Ctrl+letter</kbd>, so those shortcuts live on `<leader>` keys instead (see the tables above).
- **Ctrl+Alt+arrow** may arrive as plain <kbd>Ctrl+arrow</kbd> (common with layouts where Ctrl+Alt acts as AltGr, e.g. German). That's why <kbd>Ctrl+↑/↓</kbd> also adds cursors instead of scrolling like VS Code.
- **F11** toggles fullscreen in Windows Terminal, so "Step Into" needs `<leader>Di` there (or unbind F11 in Windows Terminal settings).
- **Shifted function keys** often arrive as <kbd>F13</kbd>–<kbd>F24</kbd> (e.g. <kbd>Shift+F5</kbd> = `<F17>`, <kbd>Shift+F11</kbd> = `<F23>`, <kbd>Shift+F12</kbd> = `<F24>`); both forms are mapped.
- **Ctrl+`** can't be sent by most terminals; the floating terminal is on <kbd>Ctrl+\</kbd>.
- **Check what your terminal sends**: run `:lua print(vim.fn.keytrans(vim.fn.getcharstr()))` and press the key. `<C-M-Down>` means Ctrl+Alt arrived; `<C-Down>` means Alt was dropped.
- **F2 / F12 without a language server**: F2 renames the word everywhere in the current file and F12 uses Vim's local `gd`. With a server attached they use the LSP. A server that is still auto-installing (first open of a new language) isn't attached yet.
- **Merge-conflict keys** only appear when Neovim's working directory is the repository root (open the project with `nvim .`).

---

## 📦 Installed Features
- **Dashboard**: `alpha-nvim` (sleek minimalist startup dashboard with quick shortcuts)
- **Theme**: Cyberdream (transparent background, terminal colors, italic comments)
- **Statusline**: `lualine.nvim` (modern rounded capsule/pill separators ``/``)
- **Command Palette & Cmdline**: `noice.nvim` (floating top-center popup for `:` and `/`, matching VS Code)
- **Breadcrumbs**: `lualine.nvim` winbar + `nvim-navic` (shows file and code hierarchy)
- **Floating Dialogs**: `snacks.nvim` input + picker (rounded popups for rename, code actions, and selections; also powers layout-preserving buffer close)
- **Toast Notifications**: `nvim-notify` (smooth animated notifications)
- **Navigation**: `flash.nvim` (<kbd>s</kbd> jump) + `better-escape.nvim` (<kbd>jk</kbd> exit)
- **Fluid Cursor**: `smear-cursor.nvim` (smooth cursor animations between lines and windows)
- **File Explorer**: `nvim-tree` with Devicons & Git indicators
- **Fuzzy Finder**: `telescope.nvim`
- **Find & Replace**: `MagicDuck/grug-far.nvim` (project-wide find & replace with live diff) + `AckslD/muren.nvim` (interactive multi-line regex replace)
- **Multi-Cursor**: `jake-stewart/multicursor.nvim` (VS Code-style multi-line editing, matching words, vertical cursors)
- **LSP**: On-demand auto-installer and launcher per filetype
- **Linting**: `nvim-lint` (runs the first installed linter per filetype — e.g. `ruff` before `flake8`, `eslint_d` before `eslint` incl. `node_modules/.bin` — on open, save, and buffer enter)
- **Formatting**: `conform.nvim` (format-on-save + Pretty JSON)
- **Syntax Highlighting**: `nvim-treesitter` (pinned to modern `main` branch for Neovim 0.12+)
- **Autocompletion**: `nvim-cmp` (LSP, path autocomplete, snippets, buffer). First suggestion is pre-selected; <kbd>Enter</kbd> / <kbd>Tab</kbd> accept it, like VS Code
- **Git**: `gitsigns.nvim`, `lazygit.nvim`, `vim-fugitive`, `diffview.nvim` (side-by-side diff & history), `git-conflict.nvim` (accept current / incoming / both)
- **Debugger**: `nvim-dap` + `nvim-dap-ui` + `nvim-dap-virtual-text` (inline variable values), `nvim-dap-python`, `nvim-dap-go`, vscode-js-debug
- **Test Runner**: `neotest` + `neotest-python`, `neotest-golang`, `neotest-jest`, `neotest-vitest`
- **Folding**: native tree-sitter folds with a VS Code-style ▾/▸ gutter (`lua/config/statuscolumn.lua`)
- **Inlay Hints**: native LSP inlay hints, on by default (`<leader>uh` toggles)
- **CSV Support**: `rainbow_csv.nvim` (colored columns & column alignment)
- **Markdown**: `render-markdown.nvim` (rich inline rendering) + `markdown-preview.nvim` + `img-clip.nvim`
- **Tabs**: `bufferline.nvim` (VS Code style top tabs)
- **Terminal**: Native Floating Terminal popup (<kbd>Ctrl+\</kbd> or `<leader>tt`)
- **TODOs**: `folke/todo-comments.nvim` (highlight, jump `]t`/`[t`, and search project TODOs)
- **Sticky Scroll**: `nvim-treesitter/nvim-treesitter-context` (VS Code-style pinned function/class headers on scroll)
- **Minimap**: `nvim-mini/mini.map` (lateral preview bar on the right side with live scrollbar, diagnostics, and git indicators)
- **Muted Scope & Delimiters**: `HiPhish/rainbow-delimiters.nvim` + `snacks.nvim` indent (subtle dark grey indent lines; the block around the cursor gets a soft, muted line coloured by nesting level). Like VS Code's active indent guide, the scope comes from indentation, so it works the same in every language and in files without a tree-sitter parser.
- **Session Manager**: `folke/persistence.nvim` (saves and restores open tabs and buffers)
- **Auto-Tags**: `windwp/nvim-ts-autotag` (auto-close & auto-rename HTML/JSX/XML tags)
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

  > The IDE features (debugger, test runner, diff view, merge conflicts) added 13 plugins: `nvim-dap`, `nvim-dap-ui`, `nvim-dap-virtual-text`, `nvim-dap-python`, `nvim-dap-go`, `nvim-nio`, `neotest`, `neotest-python`, `neotest-golang`, `neotest-jest`, `neotest-vitest`, `diffview.nvim`, `git-conflict.nvim`. Run the fork script once to back them up.

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
