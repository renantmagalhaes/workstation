return {
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
