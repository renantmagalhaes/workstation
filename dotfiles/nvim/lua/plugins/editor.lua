-- Editor Ergonomics (Autopairs, Comments, Surround, Colorizer, Rainbow Delimiters, Smear Cursor, Flash, Better Escape)
return {
  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
      })
      -- Integrate with cmp if cmp is present
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp_status, cmp = pcall(require, "cmp")
      if cmp_status then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- Commenting (gcc / gc)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Surround (ysiw", cs"', ds")
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Colorizer (Show inline hex/rgb colors)
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          RRGGBBAA = true,
          AARRGGBB = true,
          rgb_fn = true,
          hsl_fn = true,
          css = true,
          css_fn = true,
          mode = "background",
          tailwind = true,
        },
      })
    end,
  },

  -- Rainbow Delimiters (Muted, elegant bracket pairs)
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      -- Soft, muted palette (calm, non-distracting)
      local palette = {
        RainbowDelimiterRed = "#8a5555",
        RainbowDelimiterYellow = "#8a7f5a",
        RainbowDelimiterBlue = "#4f6b8a",
        RainbowDelimiterOrange = "#8a6b52",
        RainbowDelimiterGreen = "#587a5f",
        RainbowDelimiterViolet = "#7b5e8a",
        RainbowDelimiterCyan = "#4a757a",
      }
      for name, color in pairs(palette) do
        vim.api.nvim_set_hl(0, name, { fg = color })
      end

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  -- Fluid Animated Cursor (Smear Cursor)
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
      scroll_buffer_space = true,
      legacy_computing_symbols_support = false,
      smear_insert_mode = true,
    },
  },

  -- Instant Jump Navigation (Flash)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = {
          enabled = false, -- Keep standard / search unmodified
        },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Better Escape (Exit insert mode with jk / kj)
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = 200,
      default_mappings = true,
      mappings = {
        i = {
          j = {
            k = "<Esc>",
            j = "<Esc>",
          },
          k = {
            j = "<Esc>",
          },
        },
      },
    },
  },

  -- HTML/JSX/XML Auto-close and Auto-rename tags
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },

  -- TODO / FIX / NOTE / BUG Highlight and Search
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "󰙨 ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>st", "<cmd>TodoTelescope<CR>", desc = "Search TODOs (Project)" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "TODOs list (Trouble)" },
    },
  },

  -- Sticky Scroll Context (pins function/class header to top line like VS Code)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = "outer",
      mode = "topline", -- Pin to top of window like VS Code Sticky Scroll
      separator = "─",
      zindex = 20,
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      -- Apply cyberdream floating highlights for the sticky header
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "#1a1c1e", fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { bg = "#1a1c1e", fg = "#7b8496" })
      vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { fg = "#353b45" })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "#353b45" })
    end,
    keys = {
      {
        "[c",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Jump to upper context (sticky header)",
      },
      {
        "<leader>ut",
        function()
          require("treesitter-context").toggle()
        end,
        desc = "Toggle Sticky Scroll Context",
      },
    },
  },
}
