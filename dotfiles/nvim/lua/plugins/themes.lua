return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyodark",
    },
  },
  -- Make all themes with transparent BG
  -- {
  --   "xiyaowong/transparent.nvim",
  -- },
  -- {
  --   "catppuccin/nvim",
  --   lazy = false,
  --   name = "catppuccin",
  --   priority = 1000,
  --   config = function()
  --     require("catppuccin").setup({
  --       transparent_background = true,
  --     })
  --   end,
  -- },
  -- { "ellisonleao/gruvbox.nvim" },
  -- { "marko-cerovac/material.nvim" },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    -- priority = 1000,
    config = function()
      require("tokyonight").setup({
        transparent = true,
      })
    end,
  },
  {
    "tiagovla/tokyodark.nvim",
    -- enabled = false,
    -- priority = 1000,
    lazy = false,
    opts = {
      -- custom options here
      transparent_background = true,
      gamma = 1.00,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        identifiers = { italic = true },
        functions = {},
        strings = {},
        variables = {},
      },
      terminal_colors = true,
      custom_highlights = function(highlights, colors)
        return {
          TelescopeMatching = { fg = colors.orange },
          TelescopeSelection = { fg = colors.fg, bg = colors.bg1, bold = true },
          -- TelescopePromptPrefix = { bg = colors.bg1 },
          -- TelescopePromptNormal = { bg = colors.bg1 },
          -- TelescopeResultsNormal = { bg = colors.bg0 },
          -- TelescopePreviewNormal = { bg = colors.bg0 },
          --TelescopePromptBorder = { bg = colors.bg1, fg = colors.bg1 },
          -- TelescopeResultsBorder = { bg = colors.bg0, fg = colors.bg0 },
          -- TelescopePreviewBorder = { bg = colors.bg0, fg = colors.bg0 },
          TelescopePromptTitle = { bg = colors.purple, fg = colors.bg0 },
          -- TelescopeResultsTitle = { fg = colors.bg0 },
          TelescopePreviewTitle = { bg = colors.green, fg = colors.bg0 },

          PMenu = { bg = "none" }, -- make cmp menu transparent
        }
      end, -- extend highlights
    },
  },
-- {
--   "eldritch-theme/eldritch.nvim",
--   lazy = false,
--   opts = {},
-- }
}
