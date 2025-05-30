-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- Select all text
vim.keymap.set("n", "<C-a>", "ggVG", { silent = true })
vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { silent = true })

-- Save file
vim.keymap.set("n", "<C-s>", "<cmd>write<CR>", { silent = true })
vim.keymap.set("i", "<C-s>", "<cmd>write<CR>", { silent = true })

-- Exit file
vim.keymap.set("n", "<C-d>", "<cmd>qa<CR>", { silent = true })
vim.keymap.set("i", "<C-d>", "<Esc><cmd>qa<CR>", { silent = true })

-- Muren Regex
vim.keymap.set("n", "<leader>R", "<cmd>MurenToggle<CR>", { silent = true })

--REDO
vim.api.nvim_set_keymap("n", "U", "<C-r>", { noremap = true })

-- Background color for tokyodark theme
vim.cmd([[highlight Visual ctermbg=grey ctermfg=NONE guibg=#634d81 guifg=NONE]])

-- === Snacks-based mappings ===

-- 1) Current-buffer fuzzy find
--    Replaces: Telescope current_buffer_fuzzy_find
vim.keymap.set("n", "<leader>f", function()
  Snacks.picker.lines({
    layout = "default", -- same idea as above
  })
end, { noremap = true, silent = true })

-- Optionally, replicate the <C-f> in normal/insert:
vim.keymap.set("n", "<C-f>", function()
  Snacks.picker.lines({
    layout = "default", -- same idea as above
  })
end, { noremap = true, silent = true })

vim.keymap.set("i", "<C-f>", function()
  -- If you want to exit Insert mode first:
  vim.cmd("stopinsert")
  Snacks.picker.lines({
    layout = "default", -- same idea as above
  })
end, { noremap = true, silent = true })

-- 2) "Smart open"-like behavior (replaces: telescope.extensions.smart_open.smart_open)
--    Here we bind <leader><leader>. You can change the key if needed.
vim.keymap.set("n", "<leader><leader>", function()
  Snacks.picker.pick({
    -- Combine multiple sources into one
    multi = { "buffers", "recent", "files" },
    format = "file",
    hidden = true,
    -- The matcher.frecency = true will push your recently opened files up top
    matcher = {
      cwd_bonus = true,
      frecency = true,
      sort_empty = false,
      history_bonus = true,
    },
    filter = { cwd = true },
    transform = "unique_file",
    -- Optional: force a floating center layout
    layout = "default",
  })
end, { noremap = true, silent = true })

-- -- Search with telescope
-- local builtin = require("telescope.builtin")
-- vim.keymap.set("n", "<leader>f", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { noremap = true, silent = true })
-- vim.keymap.set("i", "<C-f>", "<Esc><cmd>Telescope current_buffer_fuzzy_find<CR>", { silent = true })
-- vim.keymap.set("n", "<C-f>", "<Esc><cmd>Telescope current_buffer_fuzzy_find<CR>", { silent = true })
-- vim.keymap.set("n", "<leader><leader>", function()
--   require("telescope").extensions.smart_open.smart_open()
-- end, { noremap = true, silent = true })
-- -- -- Bind command
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

-- Move selected block one line down in visual mode
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection down" })
-- Move selected block one line up in visual mode
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection up" })
-- Indent files, similar to vscode
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, silent = true, desc = "Indent selected block" })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true, desc = "Outdent selected block" })
