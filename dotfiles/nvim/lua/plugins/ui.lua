-- IDE UI Components (Tabs, Cyberdream Capsule Statusline, Breadcrumbs, Floating Dialogs, Scrollbar, Notifications)
return {
  -- VS Code style buffer tabs at top
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "[b", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous Tab" },
      { "]b", "<cmd>BufferLineCycleNext<CR>", desc = "Next Tab" },
      { "<leader>bd", "<cmd>bdelete<CR>", desc = "Close Current Buffer" },
    },
    opts = {
      options = {
        mode = "buffers",
        separator_style = "thin",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = "EXPLORER",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    },
  },

  -- Modern Capsule / Pill Statusline (Lualine with Cyberdream Palette)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      local colors = {
        bg = "#16181a",
        bg_alt = "#1e2124",
        bg_highlight = "#3c4048",
        fg = "#ffffff",
        grey = "#7b8496",
        blue = "#5ea1ff",
        green = "#5eff6c",
        cyan = "#5ef1ff",
        red = "#ff6e5e",
        yellow = "#f1ff5e",
        pink = "#ff5ea0",
        orange = "#ffbd5e",
        purple = "#bd5eff",
      }

      local cyber_bubbles = {
        normal = {
          a = { fg = colors.bg, bg = colors.purple, gui = "bold" },
          b = { fg = colors.purple, bg = colors.bg_alt },
          c = { fg = colors.fg, bg = "NONE" },
        },
        insert = {
          a = { fg = colors.bg, bg = colors.green, gui = "bold" },
          b = { fg = colors.green, bg = colors.bg_alt },
          c = { fg = colors.fg, bg = "NONE" },
        },
        visual = {
          a = { fg = colors.bg, bg = colors.pink, gui = "bold" },
          b = { fg = colors.pink, bg = colors.bg_alt },
          c = { fg = colors.fg, bg = "NONE" },
        },
        replace = {
          a = { fg = colors.bg, bg = colors.red, gui = "bold" },
          b = { fg = colors.red, bg = colors.bg_alt },
          c = { fg = colors.fg, bg = "NONE" },
        },
        command = {
          a = { fg = colors.bg, bg = colors.yellow, gui = "bold" },
          b = { fg = colors.yellow, bg = colors.bg_alt },
          c = { fg = colors.fg, bg = "NONE" },
        },
        inactive = {
          a = { fg = colors.grey, bg = colors.bg_alt },
          b = { fg = colors.grey, bg = colors.bg_alt },
          c = { fg = colors.grey, bg = "NONE" },
        },
      }

      require("lualine").setup({
        options = {
          theme = cyber_bubbles,
          icons_enabled = true,
          component_separators = "",
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = {
            {
              "mode",
              separator = { left = "", right = "" },
              icon = "",
            },
          },
          lualine_b = {
            {
              "branch",
              icon = "",
              separator = { left = "", right = "" },
            },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
              diff_color = {
                added = { fg = colors.green },
                modified = { fg = colors.orange },
                removed = { fg = colors.red },
              },
            },
          },
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
            },
          },
          lualine_x = {
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
              diagnostics_color = {
                error = { fg = colors.red },
                warn = { fg = colors.yellow },
                info = { fg = colors.cyan },
                hint = { fg = colors.purple },
              },
            },
            {
              "filetype",
              icon_only = true,
              separator = "",
            },
          },
          lualine_y = {
            {
              "progress",
              color = { fg = colors.grey, bg = colors.bg_alt },
              separator = { left = "", right = "" },
            },
          },
          lualine_z = {
            {
              "location",
              separator = { left = "", right = "" },
              color = { fg = colors.bg, bg = colors.purple, gui = "bold" },
            },
          },
        },
        extensions = { "nvim-tree", "lazy", "trouble" },
      })
    end,
  },

  -- Modern Floating UI for Inputs & Selection Dialogs
  {
    "stevearc/dressing.nvim",
    lazy = false,
    opts = {
      input = {
        border = "rounded",
        win_options = { winblend = 0 },
      },
      select = {
        backend = { "telescope", "builtin" },
        builtin = {
          border = "rounded",
          win_options = { winblend = 0 },
        },
      },
    },
  },

  -- Floating Toast Notifications (Notify)
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      stages = "fade",
      timeout = 2500,
      background_colour = "#16181a",
      render = "default",
      top_down = true,
      max_width = 50,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- VS Code-style Breadcrumbs Bar (Barbecue & Navic)
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      attach_navic = true,
      show_modified = true,
    },
  },

  -- Modern Scrollbar with Diagnostic, Git & Search Markers
  {
    "petertriho/nvim-scrollbar",
    branch = "v1", -- Pin to v1 for rock-solid stability
    dependencies = {
      "kevinhwang91/nvim-hlslens",
      "lewis6991/gitsigns.nvim",
    },
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.scrollbar_v2_notice = false -- Silence migration notice
    end,
    config = function()
      require("scrollbar").setup({
        handle = {
          color = "#3c4048",
        },
        marks = {
          Search = { color = "#ff5ea0" },
          Error = { color = "#ff6e5e" },
          Warn = { color = "#f1ff5e" },
          Info = { color = "#5ef1ff" },
          Hint = { color = "#bd5eff" },
          Misc = { color = "#5ea1ff" },
        },
      })
      require("hlslens").setup()
      require("scrollbar.handlers.search").setup()
      pcall(function()
        require("scrollbar.handlers.gitsigns").setup()
      end)
    end,
  },

  -- Keybinding helper (Which-Key)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "Find/Fuzzy" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git Hunk" },
        { "<leader>s", group = "Splits" },
        { "<leader>x", group = "Trouble/Diagnostics" },
        { "<leader>m", group = "Markdown" },
        { "<leader>c", group = "Code/Format" },
        { "<leader>b", group = "Buffer" },
      },
    },
  },

  -- Indentation guides (Indent-Blankline)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = {
          "help",
          "terminal",
          "lazy",
          "NvimTree",
          "trouble",
          "alpha",
        },
      },
    },
  },

  -- Trouble (Diagnostics & Symbol List)
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP References (Trouble)" },
    },
    opts = {},
  },
}
