return {
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "LazyFile",
    opts = function()
      LazyVim.toggle.map("<leader>ug", {
        name = "Indention Guides",
        get = function()
          return require("ibl.config").get_config(0).enabled
        end,
        set = function(state)
          require("ibl").setup_buffer(0, { enabled = state })
        end,
      })

      -- Set up highlights for indent lines
      local highlight = {
        -- "IndentLineRed",
        -- "IndentLineYellow",
        -- "IndentLineBlue",
        -- "IndentLineOrange",
        -- "IndentLineGreen",
        -- "IndentLineViolet",
        -- "IndentLineCyan",
        "IndentLineWhite",
      }

      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        -- vim.api.nvim_set_hl(0, "IndentLineRed", { fg = "#E06C75" })
        -- vim.api.nvim_set_hl(0, "IndentLineYellow", { fg = "#E5C07B" })
        -- vim.api.nvim_set_hl(0, "IndentLineBlue", { fg = "#61AFEF" })
        -- vim.api.nvim_set_hl(0, "IndentLineOrange", { fg = "#D19A66" })
        -- vim.api.nvim_set_hl(0, "IndentLineGreen", { fg = "#98C379" })
        -- vim.api.nvim_set_hl(0, "IndentLineViolet", { fg = "#C678DD" })
        -- vim.api.nvim_set_hl(0, "IndentLineCyan", { fg = "#56B6C2" })
        vim.api.nvim_set_hl(0, "IndentLineWhite", { fg = "#6c6c6c" })
      end)

      return {
        indent = {
          char = "│",
          tab_char = "│",
          highlight = highlight, -- Apply the custom highlight colors to the lines
        },
        scope = { show_start = false, show_end = false },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      }
    end,
    main = "ibl",
  },
}
