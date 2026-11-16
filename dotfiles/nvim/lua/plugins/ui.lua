-- IDE UI Components (Tabs, Cyberdream Capsule Statusline, Breadcrumbs, Floating Dialogs, Scrollbar, Notifications)
return {
  -- VS Code style buffer tabs at top
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    -- Keys ([b, ]b, <leader>bd, <leader>1-9) live in lua/config/keymaps.lua
    opts = {
      options = {
        mode = "buffers",
        -- Close tabs without collapsing the window layout (same as <leader>bd)
        close_command = function(n)
          require("snacks").bufdelete(n)
        end,
        right_mouse_command = function(n)
          require("snacks").bufdelete(n)
        end,
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
          disabled_filetypes = {
            -- No breadcrumbs on special / empty windows (minimap spacer, tree, dashboard, ...)
            winbar = {
              "",
              "NvimTree",
              "alpha",
              "dashboard",
              "trouble",
              "lazy",
              "mason",
              "help",
              "qf",
              "minimap_spacer",
              "grug-far",
              "muren",
              "TelescopePrompt",
              "noice",
              "notify",
            },
          },
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
        -- VS Code-style breadcrumbs (file › class › function) in the winbar, powered by nvim-navic
        winbar = {
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
              color = { fg = colors.grey },
            },
            {
              function()
                return require("nvim-navic").get_location()
              end,
              cond = function()
                return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
              end,
              padding = { left = 0, right = 1 },
            },
          },
        },
        inactive_winbar = {
          lualine_c = {
            { "filename", path = 1, color = { fg = colors.grey } },
          },
        },
        extensions = { "nvim-tree", "lazy", "trouble" },
      })
    end,
  },

  -- Floating input/select dialogs + layout-preserving buffer delete (replaces archived dressing.nvim)
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      input = { enabled = true }, -- vim.ui.input (LSP rename, ...) in a rounded float
      picker = {
        enabled = true,
        ui_select = true, -- vim.ui.select (code actions, ...) in a fuzzy picker
      },
      -- Everything else stays off: Telescope, nvim-notify, alpha, etc. own those jobs here
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
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

  -- Code-context provider for the winbar breadcrumbs (attached in lua/plugins/lsp.lua)
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    opts = {
      highlight = true,
      separator = " › ",
      depth_limit = 6,
      lazy_update_context = true,
    },
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
        { "<leader>s", group = "Search/Replace & Splits" },
        { "<leader>x", group = "Trouble/Diagnostics" },
        { "<leader>m", group = "Minimap / Markdown" },
        { "<leader>u", group = "UI Toggles" },
        { "<leader>c", group = "Code/Format" },
        { "<leader>b", group = "Buffer" },
        { "<leader>q", group = "Session / Quit" },
        { "<leader>t", group = "Terminal" },
        { "<leader>p", group = "Pretty / Paste" },
      },
    },
  },

  -- Indentation guides & Function Scope Lines (Indent-Blankline v3)
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }

      local hooks = require("ibl.hooks")
      -- Soft, muted color palette for delimiters and function scope lines
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        -- Subtle dark slate grey for all standard indent guides (quiet and non-distracting)
        vim.api.nvim_set_hl(0, "IblIndent", { fg = "#2c313a" })
        vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#22252a" })

        local palette = {
          RainbowRed = "#8a5555",    -- Muted dusky rose
          RainbowYellow = "#8a7f5a", -- Muted warm gold/amber
          RainbowBlue = "#4f6b8a",   -- Muted slate denim blue
          RainbowOrange = "#8a6b52", -- Muted terracotta
          RainbowGreen = "#587a5f",  -- Muted sage/olive
          RainbowViolet = "#7b5e8a", -- Muted lavender/plum
          RainbowCyan = "#4a757a",   -- Muted teal/slate
        }
        for name, color in pairs(palette) do
          vim.api.nvim_set_hl(0, name, { fg = color })
          local delim_name = "RainbowDelimiter" .. name:gsub("^Rainbow", "")
          vim.api.nvim_set_hl(0, delim_name, { fg = color })
        end
      end)

      require("ibl").setup({
        indent = {
          char = "│",
          tab_char = "│",
          highlight = "IblIndent", -- Standard indentation lines are subtle muted dark grey!
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
          highlight = highlight, -- ONLY the active function scope line gets the soft muted color!
        },
        exclude = {
          filetypes = {
            "help",
            "terminal",
            "lazy",
            "NvimTree",
            "trouble",
            "alpha",
            "dashboard",
          },
        },
      })

      -- Colorize function scope line based on active delimiter extmark
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
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
