return {
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("lualine").setup({
  --       options = {
  --         theme = "catppuccin",
  --       },
  --     })
  --   end,
  -- },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
        },
        -- Define the winbar to display lualine at the top
        winbar = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" }, -- Git diff and LSP diagnostics
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        -- Disable the default statusline at the bottom
        sections = {},
      })
    end,
  },
  -- {
  --   "sontungexpt/sttusline",
  --   dependencies = {
  --     "nvim-tree/nvim-web-devicons",
  --   },
  --   event = { "BufEnter" },
  --   config = function(_, opts)
  --     require("sttusline").setup({
  --       -- statusline_color = "#000000",
  --       statusline_color = "StatusLine",
  --
  --       -- | 1 | 2 | 3
  --       -- recommended: 3
  --       laststatus = 3,
  --       disabled = {
  --         filetypes = {
  --           -- "NvimTree",
  --           -- "lazy",
  --         },
  --         buftypes = {
  --           -- "terminal",
  --         },
  --       },
  --       components = {
  --         "mode",
  --         "filename",
  --         "git-branch",
  --         "git-diff",
  --         "%=",
  --         "diagnostics",
  --         "lsps-formatters",
  --         "copilot",
  --         "indent",
  --         "encoding",
  --         "pos-cursor",
  --         "pos-cursor-progress",
  --       },
  --     })
  --   end,
  -- },
}
