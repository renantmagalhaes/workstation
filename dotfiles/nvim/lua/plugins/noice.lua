-- Modern Floating Command Palette & Cmdline (VS Code style)
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline_popup", -- floating popup at center/top
        format = {
          cmdline = { pattern = "^:", icon = " : ", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = "   ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = "   ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = " $ ", lang = "bash" },
          lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "  ", lang = "lua" },
          help = { pattern = "^:%s*he?l?p?%s+", icon = " 󰋖 " },
        },
      },
      popupmenu = {
        enabled = true,
        backend = "nui",
      },
      presets = {
        bottom_search = false, -- floating cmdline for search too
        command_palette = false, -- false allows custom centralized positioning
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      views = {
        cmdline_popup = {
          position = {
            row = "40%",
            col = "50%",
          },
          size = {
            min_width = 60,
            width = "auto",
            height = "auto",
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
        cmdline_popupmenu = {
          relative = "editor",
          position = {
            row = "44%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
            max_height = 15,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
      },
      routes = {
        -- Skip noisy buffer write messages on save (kind is "bufwrite" since Neovim 0.11)
        {
          filter = {
            event = "msg_show",
            any = {
              { kind = "bufwrite" },
              { kind = "", find = "written" },
            },
          },
          opts = { skip = true },
        },
      },
    },
  },
}
