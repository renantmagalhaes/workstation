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
  -- {
  --   "b0o/incline.nvim",
  --   config = function()
  --     local devicons = require("nvim-web-devicons")
  --     require("incline").setup({
  --       debounce_threshold = {
  --         falling = 50,
  --         rising = 10,
  --       },
  --       hide = {
  --         cursorline = false,
  --         focused_win = false,
  --         only_win = false,
  --       },
  --       highlight = {
  --         groups = {
  --           InclineNormal = {
  --             default = true,
  --             group = "NormalFloat",
  --           },
  --           InclineNormalNC = {
  --             default = true,
  --             group = "NormalFloat",
  --           },
  --         },
  --       },
  --       ignore = {
  --         buftypes = "special",
  --         filetypes = {},
  --         floating_wins = true,
  --         unlisted_buffers = true,
  --         wintypes = "special",
  --       },
  --       -- Modify the render function to include Git signs
  --       render = function(props)
  --         local bufname = vim.api.nvim_buf_get_name(props.buf)
  --         local filename = vim.fn.fnamemodify(bufname, ":t")
  --         if filename == "" then
  --           filename = "[No Name]"
  --         end
  --         local ft_icon, ft_color = devicons.get_icon_color(filename)
  --         local modified = vim.bo[props.buf].modified
  --
  --         -- Function to get Git diff signs
  --         local function get_git_diff()
  --           local icons = { added = " ", changed = " ", removed = " " }
  --           local signs = vim.b[props.buf].gitsigns_status_dict
  --           local labels = {}
  --           if signs == nil then
  --             return labels
  --           end
  --           for name, icon in pairs(icons) do
  --             if tonumber(signs[name]) and signs[name] > 0 then
  --               table.insert(labels, { icon .. signs[name], group = "Diff" .. name })
  --             end
  --           end
  --           if #labels > 0 then
  --             table.insert(labels, { " ", guifg = "#FFFFFF" }) -- Add space between Git signs and filename
  --           end
  --           return labels
  --         end
  --
  --         return {
  --           { get_git_diff() },
  --           ft_icon and { ft_icon, guifg = ft_color } or "",
  --           { " " },
  --           { filename, gui = modified and "bold,italic" or "bold" },
  --           modified and { " [+]", guifg = "#ff9e64" } or "", -- Indicate if buffer is modified
  --         }
  --       end,
  --       window = {
  --         margin = {
  --           horizontal = 1,
  --           vertical = 1,
  --         },
  --         options = {
  --           signcolumn = "no",
  --           wrap = false,
  --         },
  --         overlap = {
  --           borders = true,
  --           statusline = false,
  --           tabline = false,
  --           winbar = false,
  --         },
  --         padding = 1,
  --         padding_char = " ",
  --         placement = {
  --           horizontal = "right",
  --           vertical = "top",
  --         },
  --         width = "fit",
  --         winhighlight = {
  --           active = {
  --             EndOfBuffer = "None",
  --             Normal = "InclineNormal",
  --             Search = "None",
  --           },
  --           inactive = {
  --             EndOfBuffer = "None",
  --          -   Normal = "InclineNormalNC",
  --             Search = "None",
  --           },
  --         },
  --         zindex = 50,
  --       },
  --     })
  --   end,
  --   -- Optional: Lazy load Incline
  --   event = "VeryLazy",
  -- },
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   config = function()
  --     require("lualine").setup({
  --       options = {
  --         theme = "tokyonight",
  --       },
  --     })
  --   end,
  --   opts = function(_, opts)
  --     local trouble = require("trouble")
  --     local symbols = trouble.statusline({
  --       mode = "lsp_document_symbols",
  --       groups = {},
  --       title = false,
  --       filter = { range = true },
  --       format = "{kind_icon}{symbol.name:Normal}",
  --       -- The following line is needed to fix the background color
  --       -- Set it to the lualine section you want to use
  --       hl_group = "lualine_c_normal",
  --     })
  --     table.insert(opts.sections.lualine_c, {
  --       symbols.get,
  --       cond = symbols.has,
  --     })
  --   end,
  -- },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      local lualine = require("lualine")

      -- Merge colors from both configurations
      local colors = {
        bg = nil,
        fg = "#bbc2cf",
        yellow = "#ECBE7B",
        cyan = "#00ffff",
        darkblue = "#081633",
        green = "#98be65",
        orange = "#FF8800",
        violet = "#a9a1e1",
        magenta = "#ff00ff",
        blue = "#51afef",
        red = "#ec5f67",
        white = "#ffffff",
        truewhite = "#ffffff", -- From bubble theme
        black = "#080808", -- From bubble theme
        grey = "#303030", -- From bubble theme
      }

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand("%:p:h")
          local gitdir = vim.fn.finddir(".git", filepath .. ";")
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      -- Bubble theme configuration
      local bubbles_theme = {
        normal = {
          a = { fg = colors.black, bg = colors.violet },
          b = { fg = colors.white, bg = colors.grey },
          c = { fg = colors.white, bg = colors.bg },
        },
        insert = { a = { fg = colors.black, bg = colors.blue } },
        visual = { a = { fg = colors.black, bg = colors.cyan } },
        replace = { a = { fg = colors.black, bg = colors.red } },
        inactive = {
          a = { fg = colors.white, bg = colors.black },
          b = { fg = colors.white, bg = colors.black },
          c = { fg = colors.white, bg = colors.bg },
        },
      }

      local config = {
        options = {
          component_separators = "",
          section_separators = { left = "", right = "" },
          theme = bubbles_theme,
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        inactive_sections = {
          lualine_a = { "filename" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "location" },
        },
      }

      -- Insert components into lualine sections

      -- Left section (mode)
      config.sections.lualine_a = {
        {
          function()
            -- Define the icon in one place
            local mode_icon = ""

            -- Define the mode names
            local mode_map = {
              n = mode_icon .. " NORMAL",
              i = mode_icon .. " INSERT",
              v = mode_icon .. " VISUAL",
              [""] = mode_icon .. " VISUAL BLOCK",
              V = mode_icon .. " VISUAL LINE",
              c = mode_icon .. " COMMAND",
              no = mode_icon .. " NORMAL",
              s = mode_icon .. " SELECT",
              S = mode_icon .. " SELECT LINE",
              [""] = mode_icon .. " SELECT BLOCK",
              ic = mode_icon .. " INSERT COMPLETION",
              R = mode_icon .. " REPLACE",
              Rv = mode_icon .. " VISUAL REPLACE",
              cv = mode_icon .. " VIM EX",
              ce = mode_icon .. " NORMAL EX",
              r = mode_icon .. " HIT-ENTER",
              rm = mode_icon .. " MORE",
              ["r?"] = mode_icon .. " CONFIRM",
              ["!"] = mode_icon .. " SHELL",
              t = mode_icon .. " TERMINAL",
            }

            -- Return the corresponding mode name with the icon
            return mode_map[vim.fn.mode()] or (mode_icon .. " UNKNOWN")
          end,
          color = function()
            local mode_color = {
              n = colors.red,
              i = colors.green,
              v = colors.blue,
              [""] = colors.blue,
              V = colors.blue,
              c = colors.white,
              no = colors.red,
              s = colors.orange,
              S = colors.orange,
              [""] = colors.orange,
              ic = colors.yellow,
              R = colors.violet,
              Rv = colors.violet,
              cv = colors.red,
              ce = colors.red,
              r = colors.cyan,
              rm = colors.cyan,
              ["r?"] = colors.cyan,
              ["!"] = colors.red,
              t = colors.red,
            }
            return { fg = mode_color[vim.fn.mode()], bg = colors.black }
          end,
          separator = { left = "", right = "" },
          right_padding = 2,
        },
      }

      -- Left section (branch and diff)
      config.sections.lualine_b = {
        {
          "branch",
          icon = "",
          color = { fg = colors.magenta, gui = "bold" },
        },
        {
          "diff",
          symbols = { added = " ", modified = "󰝤 ", removed = " " },
          diff_color = {
            added = { fg = colors.green },
            modified = { fg = colors.orange },
            removed = { fg = colors.red },
          },
          cond = conditions.hide_in_width,
        },
      }

      -- Center section (filename centered and inside bubble separators)
      config.sections.lualine_c = {
        {
          function()
            return " "
          end, -- This dummy component creates a gap
          color = { bg = colors.bg }, -- Ensures the gap blends with the background
          padding = { left = 1, right = 1 }, -- Adjusts the gap size
        },
        {
          "filetype",
          fmt = string.upper,
          icons_enabled = true,
          color = { fg = colors.green, bg = colors.grey, gui = "bold" },
          separator = { left = "", right = "" },
        },
        {
          "filename",
          cond = conditions.buffer_not_empty,
          path = 3, -- Show the relative filepath
          color = { fg = colors.black, bg = colors.truewhite, gui = "bold" },
          separator = { left = "", right = "" },
        },
      }

      -- Right section (LSP, filetype, progress)
      config.sections.lualine_y = {
        {
          function()
            local msg = "No Active Lsp"
            local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
            local clients = vim.lsp.get_active_clients()
            if next(clients) == nil then
              return msg
            end
            for _, client in ipairs(clients) do
              local filetypes = client.config.filetypes
              if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
              end
            end
            return msg
          end,
          icon = " LSP:",
          color = { fg = colors.cyan, gui = "bold" },
        },
        {
          "progress",
          color = { fg = colors.fg, gui = "bold" },
        },
      }

      -- Right-most section (location)
      config.sections.lualine_z = {
        {
          "location",
          separator = { left = "", right = "" },
          color = { fg = colors.white },
          left_padding = 2,
        },
      }

      lualine.setup(config)
    end,
  },
}
