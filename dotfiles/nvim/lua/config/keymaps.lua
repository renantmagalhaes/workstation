-- Keymaps configuration
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ==========================================
-- Core Requested Keymaps
-- ==========================================

-- Save with Ctrl+s (Normal, Insert, Visual)
map("n", "<C-s>", "<cmd>write<CR>", { desc = "Save file", silent = true })
map("i", "<C-s>", "<Esc><cmd>write<CR>a", { desc = "Save file", silent = true })
map("v", "<C-s>", "<Esc><cmd>write<CR>gv", { desc = "Save file", silent = true })

-- Exit with Ctrl+d (Prompt to save if unsaved changes exist)
map("n", "<C-d>", "<cmd>confirm qa<CR>", { desc = "Exit with save prompt", silent = true })
map("i", "<C-d>", "<Esc><cmd>confirm qa<CR>", { desc = "Exit with save prompt", silent = true })
map("v", "<C-d>", "<Esc><cmd>confirm qa<CR>", { desc = "Exit with save prompt", silent = true })

-- Fuzzy search inline (Ctrl+f)
map("n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search inside buffer", silent = true })
map("i", "<C-f>", "<Esc><cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search inside buffer", silent = true })
map("n", "<leader>f", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search inside buffer", silent = true })

-- Fuzzy search across whole folder (Space Space)
map("n", "<leader><leader>", "<cmd>Telescope find_files hidden=true<CR>", { desc = "Find files in project", silent = true })

-- Grep across whole folder / project
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep across project", silent = true })
map("n", "<leader>/", "<cmd>Telescope live_grep<CR>", { desc = "Live grep across project", silent = true })

-- Additional Telescope pickers
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find open buffers", silent = true })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files", silent = true })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags", silent = true })

-- Lateral Tree Bar (NvimTree)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree", silent = true })
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree (VS Code style)", silent = true })
map("n", "<leader>o", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal file in tree", silent = true })

-- Lazygit
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit", silent = true })
map("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit", silent = true })

-- Pretty JSON (<leader>pj)
map("n", "<leader>pj", function()
  -- Try jq if available, otherwise python json.tool, otherwise LSP/conform format
  if vim.fn.executable("jq") == 1 then
    vim.cmd("%!jq .")
  elseif vim.fn.executable("python3") == 1 then
    vim.cmd("%!python3 -m json.tool")
  else
    vim.lsp.buf.format({ async = false })
  end
end, { desc = "Pretty JSON (Format buffer)", silent = true })

-- Paste image from clipboard
map("n", "<leader>p", "<cmd>PasteImage<CR>", { desc = "Paste image from clipboard", silent = true })
map("n", "<leader>P", "<cmd>PasteImage<CR>", { desc = "Paste image from clipboard", silent = true })

-- Markdown Preview Toggle
map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview", silent = true })

-- Code formatting (<leader>cf or <leader>fm)
map({ "n", "v" }, "<leader>cf", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
  else
    vim.lsp.buf.format({ async = false })
  end
end, { desc = "Format document", silent = true })

map({ "n", "v" }, "<leader>fm", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
  else
    vim.lsp.buf.format({ async = false })
  end
end, { desc = "Format document", silent = true })

-- ==========================================
-- VS Code-Style & Everyday Ergonomics
-- ==========================================

-- Select all (<C-a>)
map("n", "<C-a>", "ggVG", { desc = "Select all", silent = true })
map("i", "<C-a>", "<Esc>ggVG", { desc = "Select all", silent = true })

-- Redo with U
map("n", "U", "<C-r>", { desc = "Redo", noremap = true })

-- Clear search highlight on Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- Clipboard copy & paste
map("i", "<C-c>", '"+yy', { desc = "Copy line in insert mode", silent = true })
map("i", "<C-v>", "<C-r>+", { desc = "Paste in insert mode", silent = true })
map("v", "<C-c>", '"+y', { desc = "Copy selection", silent = true })
map("v", "<C-v>", '"_dP', { desc = "Paste replacing selection", silent = true })

-- Move lines up/down in Visual mode (Alt+j / Alt+k)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Indent / Outdent in Visual mode (Tab / Shift-Tab)
map("v", "<Tab>", ">gv", { desc = "Indent selection", silent = true })
map("v", "<S-Tab>", "<gv", { desc = "Outdent selection", silent = true })

-- Buffer navigation (tabs at top)
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer", silent = true })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer", silent = true })
map("n", "<leader>bc", "<cmd>bdelete<CR>", { desc = "Close buffer", silent = true })

-- Quick jump to tabs 1-9
for i = 1, 9 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i, silent = true })
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window", silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window", silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window", silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window", silent = true })

-- Window splits
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertically", silent = true })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally", silent = true })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal", silent = true })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split", silent = true })

-- Diagnostics (Trouble / LSP)
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Toggle Trouble Diagnostics", silent = true })
map("n", "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer Diagnostics", silent = true })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic", silent = true })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic", silent = true })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics popup", silent = true })
