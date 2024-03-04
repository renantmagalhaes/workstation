local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("lazy").setup("plugins")

--keymaps
-- --Save file
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>:echo "File saved"<CR>', { noremap = true, silent = false })
-- -- Exit
vim.api.nvim_set_keymap('n', '<C-w>', ':q<CR>:echo "File saved"<CR>', { noremap = true, silent = false })
