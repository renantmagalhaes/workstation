return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function() end,
  },

  { "ellisonleao/gruvbox.nvim" },
  { "marko-cerovac/material.nvim" },

  -- Configure LazyVim to load gruvbox
}
