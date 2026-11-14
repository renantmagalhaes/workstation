-- Colorscheme and Icons
return {
  -- Web Devicons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    priority = 1000,
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
      })
    end,
  },

  -- Primary Theme: Cyberdream
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        variant = "default",
        transparent = true,
        italic_comments = true,
        borderless_pickers = false,
        terminal_colors = true,
        cache = false,
        theme = {
          highlights = {
            Comment = { fg = "#7b8496", italic = true },
          },
        },
        extensions = {
          telescope = true,
          notify = true,
          treesitter = true,
          whichkey = true,
        },
      })
      vim.cmd("colorscheme cyberdream")
    end,
  },

  -- Fallback Theme: Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      transparent_background = true,
    },
  },
}
