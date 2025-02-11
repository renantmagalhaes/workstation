-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = vim.fn.expand("~/.ssh/config"),
  callback = function()
    vim.bo.filetype = "sshconfig"
  end,
})
-- Remove Snacks Explorer keybindings
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.isdirectory(vim.fn.argv()[1] or "") == 1 then
      require("neo-tree.command").execute({ toggle = true, dir = vim.fn.argv()[1] })
    end
  end,
})
