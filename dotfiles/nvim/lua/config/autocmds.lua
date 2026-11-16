-- Autocmds configuration
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General group
local general_group = augroup("GeneralSettings", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
  group = general_group,
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
  desc = "Briefly highlight yanked text",
})

-- Return to last cursor position when reopening a file
autocmd("BufReadPost", {
  group = general_group,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor position",
})

-- Close utility/help windows easily with 'q'
autocmd("FileType", {
  group = general_group,
  pattern = {
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "checkhealth",
    "gitsigns-blame",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
  desc = "Close with q",
})

-- Check if file changed outside of neovim when focusing
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = general_group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
  desc = "Reload buffer when changed externally",
})

-- Auto-wrap and spell check in text / markdown files
autocmd("FileType", {
  group = general_group,
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  desc = "Enable wrap and spell in markdown/gitcommit",
})

-- Custom filetype detection
vim.filetype.add({
  -- NOTE: no bare `config` filename rule — it would turn .git/config, i3/config, etc. into sshconfig.
  -- Neovim already detects ~/.ssh/config and /etc/ssh/ssh_config on its own.
  pattern = {
    [".*/%.ssh/config%.d/.*"] = "sshconfig",
  },
  extension = {
    ["tf"] = "terraform",
    ["tfvars"] = "terraform",
  },
})
