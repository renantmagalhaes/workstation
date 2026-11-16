-- Options configuration
local opt = vim.opt

-- Set leader key to Space
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & Indentation (VS Code style 2 spaces default)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line & visual cues
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.colorcolumn = ""

-- Window split direction
opt.splitright = true
opt.splitbelow = true

-- Clipboard (sync with system clipboard)
opt.clipboard = "unnamedplus"

-- Scrolling ergonomics
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Persistent Undo & Files
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Performance & responsiveness
opt.updatetime = 200
opt.timeoutlen = 300

-- Mouse support
opt.mouse = "a"

-- Confirm before exiting when unsaved changes exist
opt.confirm = true

-- Completion options
opt.completeopt = { "menu", "menuone", "noselect" }

-- Code folding (VS Code style): syntax-aware folds from tree-sitter, all open on file load,
-- with ▾/▸ markers next to the line number (lua/config/statuscolumn.lua).
-- zc / zo / za close / open / toggle a fold, zM / zR fold / unfold everything; or click the marker.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = "" -- show the folded line itself (with its syntax highlighting)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "0" -- the markers are drawn by 'statuscolumn' instead
opt.statuscolumn = require("config.statuscolumn").expr

-- Fillchars
opt.fillchars = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸", foldsep = " " }
