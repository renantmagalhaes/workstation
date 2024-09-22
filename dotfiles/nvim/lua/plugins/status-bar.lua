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
      local colors = {
        bg = "#202328",
        fg = "#bbc2cf",
        yellow = "#ECBE7B",
        cyan = "#008080",
        darkblue = "#081633",
        green = "#98be65",
        orange = "#FF8800",
        violet = "#a9a1e1",
        magenta = "#c678dd",
        blue = "#51afef",
        red = "#ec5f67",
        white = "#ffffff",
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

      local config = {
        options = {
          component_separators = "",
          section_separators = "",
          theme = {
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
          },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
      end

      local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
      end

      ins_left({
        function()
          return "▊"
        end,
        color = { fg = colors.blue },
        padding = { left = 0, right = 1 },
      })

      ins_left({
        function()
          -- Define the icon in one place
          local mode_icon = ""
          -- local mode_icon = ""

          -- Define the mode names
          local mode_map = {
            n = mode_icon .. " NORMAL",
            i = mode_icon .. " INSERT",
            v = mode_icon .. " VISUAL",
            [""] = mode_icon .. " VISUAL BLOCK",
            V = mode_icon .. " VISUAL LINE",
            c = mode_icon .. " COMMAND",
            no = mode_icon .. " NORMAL",
            s = mode_icon .. " SELECT",
            S = mode_icon .. " SELECT LINE",
            [""] = mode_icon .. " SELECT BLOCK",
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
            [""] = colors.blue,
            V = colors.blue,
            c = colors.magenta,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [""] = colors.orange,
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
          return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { right = 1 },
      })

      ins_left({
        "filesize",
        cond = conditions.buffer_not_empty,
      })

      -- Update the filename component to show the full path
      ins_left({
        "filename",
        cond = conditions.buffer_not_empty,
        path = 3, -- Show the relative filepath
        color = { fg = colors.white, gui = "bold" },
      })

      ins_left({ "location" })
      ins_left({ "progress", color = { fg = colors.fg, gui = "bold" } })

      ins_left({
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " " },
        diagnostics_color = {
          error = { fg = colors.red },
          warn = { fg = colors.yellow },
          info = { fg = colors.cyan },
        },
      })

      ins_left({
        function()
          return "%="
        end,
      })

      -- Move the LSP section to the right
      ins_right({
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
        color = { fg = colors.blue, gui = "bold" },
      })

      -- ins_right({
      --   "o:encoding",
      --   fmt = string.upper,
      --   cond = conditions.hide_in_width,
      --   color = { fg = colors.green, gui = "bold" },
      -- })
      --
      -- ins_right({
      --   "fileformat",
      --   fmt = string.upper,
      --   icons_enabled = false,
      --   color = { fg = colors.green, gui = "bold" },
      -- })

      ins_right({
        "filetype",
        fmt = string.upper,
        icons_enabled = true,
        color = { fg = colors.green, gui = "bold" },
      })

      ins_right({
        "branch",
        icon = "",
        color = { fg = colors.violet, gui = "bold" },
      })

      ins_right({
        "diff",
        symbols = { added = " ", modified = "󰝤 ", removed = " " },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.orange },
          removed = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
      })

      ins_right({
        function()
          return "▊"
        end,
        color = { fg = colors.blue },
        padding = { left = 1 },
      })

      lualine.setup(config)
    end,
  },
}
