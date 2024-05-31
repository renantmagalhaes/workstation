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
      })
    end,
    opts = function(_, opts)
      local trouble = require("trouble")
      local symbols = trouble.statusline({
        mode = "lsp_document_symbols",
        groups = {},
        title = false,
        filter = { range = true },
        format = "{kind_icon}{symbol.name:Normal}",
        -- The following line is needed to fix the background color
        -- Set it to the lualine section you want to use
        hl_group = "lualine_c_normal",
      })
      table.insert(opts.sections.lualine_c, {
        symbols.get,
        cond = symbols.has,
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
