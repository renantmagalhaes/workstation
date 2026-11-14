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

-- Fillchars
opt.fillchars = { eob = " " }
