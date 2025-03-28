--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   pattern = { "config", "config.d/*" },
--   callback = function(args)
--     -- args.file is the absolute path Neovim opened
--     local parent = vim.fn.fnamemodify(args.file, ":h")
--     local ssh_dir = vim.fn.expand("$HOME/.ssh")
--     if parent == ssh_dir then
--       vim.bo.filetype = "sshconfig"
--     end
--   end,
-- })

vim.filetype.add({
  filename = {
    ["config"] = "sshconfig",
  },
})
