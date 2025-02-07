return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cyberdream",
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
  --   -- priority = 1000,
  --   config = function()
  --     require("catppuccin").setup({
  --       transparent_background = true,
  --     })
  --   end,
  -- },
  -- { "ellisonleao/gruvbox.nvim" },
  -- { "marko-cerovac/material.nvim" },
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   -- priority = 1000,
  --   config = function()
  --     require("tokyonight").setup({
  --       transparent = true,
  --     })
  --   end,
  -- },
  -- {
  --   "tiagovla/tokyodark.nvim",
  --   -- enabled = false,
  --   -- priority = 1000,
  --   lazy = false,
  --   opts = {
  --     -- custom options here
  --     transparent_background = true,
  --     gamma = 1.00,
  --     styles = {
  --       comments = { italic = true },
  --       keywords = { italic = true },
  --       identifiers = { italic = true },
  --       functions = {},
  --       strings = {},
  --       variables = {},
  --     },
  --     terminal_colors = true,
  --     custom_highlights = function(highlights, colors)
  --       return {
  --         TelescopeMatching = { fg = colors.orange },
  --         TelescopeSelection = { fg = colors.fg, bg = colors.bg1, bold = true },
  --         -- TelescopePromptPrefix = { bg = colors.bg1 },
  --         -- TelescopePromptNormal = { bg = colors.bg1 },
  --         -- TelescopeResultsNormal = { bg = colors.bg0 },
  --         -- TelescopePreviewNormal = { bg = colors.bg0 },
  --         --TelescopePromptBorder = { bg = colors.bg1, fg = colors.bg1 },
  --         -- TelescopeResultsBorder = { bg = colors.bg0, fg = colors.bg0 },
  --         -- TelescopePreviewBorder = { bg = colors.bg0, fg = colors.bg0 },
  --         TelescopePromptTitle = { bg = colors.purple, fg = colors.bg0 },
  --         -- TelescopeResultsTitle = { fg = colors.bg0 },
  --         TelescopePreviewTitle = { bg = colors.green, fg = colors.bg0 },
  --
  --         PMenu = { bg = "none" }, -- make cmp menu transparent
  --       }
  --     end, -- extend highlights
  --   },
  -- },
  -- {
  --   "eldritch-theme/eldritch.nvim",
  --   lazy = false,
  --   opts = {},
  --   config = function()
  --     require("eldritch").setup({
  --       -- your configuration comes here
  --       -- or leave it empty to use the default settings
  --       transparent = false, -- Enable this to disable setting the background color
  --       terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
  --       styles = {
  --         -- Style to be applied to different syntax groups
  --         -- Value is any valid attr-list value for `:help nvim_set_hl`
  --         comments = { italic = true },
  --         keywords = { italic = true },
  --         functions = {},
  --         variables = {},
  --         -- Background styles. Can be "dark", "transparent" or "normal"
  --         sidebars = "dark", -- style for sidebars, see below
  --         floats = "dark", -- style for floating windows
  --       },
  --       sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
  --       hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
  --       dim_inactive = false, -- dims inactive windows, transparent must be false for this to work
  --       lualine_bold = true, -- When `true`, section headers in the lualine theme will be bold
  --
  --       --- You can override specific color groups to use other groups or a hex color
  --       --- function will be called with a ColorScheme table
  --       ---@param colors ColorScheme
  --       on_colors = function(colors) end,
  --
  --       --- You can override specific highlights to use other groups or a hex color
  --       --- function will be called with a Highlights and ColorScheme table
  --       ---@param highlights Highlights
  --       ---@param colors ColorScheme
  --       on_highlights = function(highlights, colors) end,
  --     })
  --   end,
  -- },
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        -- Recommended - see "Configuring" below for more config options
        transparent = true,
        italic_comments = true,
        hide_fillchars = true,
        borderless_pickers = true,
        terminal_colors = true,
      })
    end,
  },
}
