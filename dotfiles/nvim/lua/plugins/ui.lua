-- IDE UI Components (Tabs, Statusline, Indent guides, Which-Key, Trouble)
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

  -- Statusline (Lualine)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          theme = "cyberdream",
          icons_enabled = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { { "mode", icon = "" } },
          lualine_b = { "branch", "diff" },
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
            },
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "nvim-tree", "lazy", "trouble" },
      })
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
