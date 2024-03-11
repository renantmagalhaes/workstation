return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
    end,
  },
  { "ellisonleao/gruvbox.nvim" },
  { "marko-cerovac/material.nvim" },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        transparent = true,
      })
    end,
  },
  {
    "tiagovla/tokyodark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyodark").setup({
        transparent_background = true,
      })
    end,
  },
}
