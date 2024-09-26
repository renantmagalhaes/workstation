-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local builtin = require("telescope.builtin")
-- vim.keymap.set("n", "<C-p>", builtin.find_files, {})
-- vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})

-- Select all text
vim.keymap.set("n", "<C-a>", "ggVG", { silent = true })
vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { silent = true })

-- Save file
vim.keymap.set("n", "<C-s>", "<cmd>write<CR>", { silent = true })
vim.keymap.set("i", "<C-s>", "<cmd>write<CR>", { silent = true })

-- Exit file
vim.keymap.set("n", "<C-d>", "<cmd>q<CR>", { silent = true })
vim.keymap.set("i", "<C-d>", "<Esc><cmd>q<CR>", { silent = true })

-- Muren Regex
vim.keymap.set("n", "<leader>R", "<cmd>MurenToggle<CR>", { silent = true })

--REDO
vim.api.nvim_set_keymap("n", "U", "<C-r>", { noremap = true })

-- Background color for tokyodark theme
vim.cmd([[highlight Visual ctermbg=grey ctermfg=NONE guibg=#634d81 guifg=NONE]])

-- Search with telescope
vim.keymap.set("n", "<leader>f", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-f>", "<Esc><cmd>Telescope current_buffer_fuzzy_find<CR>", { silent = true })
vim.keymap.set("n", "<C-f>", "<Esc><cmd>Telescope current_buffer_fuzzy_find<CR>", { silent = true })
vim.keymap.set("n", "<leader><leader>", function()
  require("telescope").extensions.smart_open.smart_open()
end, { noremap = true, silent = true })
-- -- Bind command
-- vim.keymap.set("n", "<leader><leader>", "<Cmd>Telescope frecency<CR>")
-- -- Bind Lua function directly
-- vim.keymap.set("n", "<leader><leader>", function()
--   require("telescope").extensions.frecency.frecency {}
-- end)

-- surround
-- -- add surrounding pairs normal mode
vim.keymap.set("n", "<leader>'", "ysiw'", { remap = true })
vim.keymap.set("n", '<leader>"', 'ysiw"', { remap = true })
vim.keymap.set("n", "<leader>`", "ysiw`", { remap = true })
vim.keymap.set("n", "<leader>(", "ysiw(", { remap = true })
vim.keymap.set("n", "<leader>{", "ysiw{", { remap = true })
vim.keymap.set("n", "<leader>[", "ysiw[", { remap = true })
-- -- remove surrounding pairs normal mode
--vim.keymap.set('n', "<leader>Del", "dsq",{ remap = true })
-- -- add surrounding pairs inset mode
--TBD
--
-- COPY and PASTE insert and visual mode
-- Insert mode mappings
-- Map Ctrl+C to copy the current line in insert mode
vim.api.nvim_set_keymap("i", "<C-c>", '"+yy', { noremap = true, silent = true })

-- Map Ctrl+V to paste in insert mode
vim.api.nvim_set_keymap("i", "<C-v>", "<C-r>+", { noremap = true, silent = true })

-- Visual mode mappings
-- Map Ctrl+C to copy the selected text in visual mode
vim.api.nvim_set_keymap("v", "<C-c>", '"+y', { noremap = true, silent = true })

-- Map Ctrl+V to paste in visual mode (replace selection with clipboard content)
vim.api.nvim_set_keymap("v", "<C-v>", '"_dP', { noremap = true, silent = true })
