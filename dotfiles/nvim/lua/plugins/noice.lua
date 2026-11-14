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
        command_palette = true, -- positions the cmdline and popupmenu together at top-center!
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        -- Skip noisy buffer write messages on save
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
      },
    },
  },
}
