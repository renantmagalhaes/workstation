-- Search & Replace Tools (Buffer & Project-wide)
return {
  -- 1. Project-wide Find & Replace (ripgrep-powered with live diff)
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = (ext and ext ~= "") and ("*." .. ext) or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace (Project)",
      },
      {
        "<leader>sf",
        function()
          local grug = require("grug-far")
          grug.open({
            transient = true,
            prefills = {
              paths = vim.fn.expand("%"),
            },
          })
        end,
        desc = "Search and Replace (Current File)",
      },
      {
        "<leader>sw",
        function()
          local grug = require("grug-far")
          grug.open({
            transient = true,
            prefills = {
              search = vim.fn.expand("<cword>"),
            },
          })
        end,
        desc = "Search and Replace Word Under Cursor",
      },
    },
    opts = {
      headerMaxWidth = 80,
    },
  },

  -- 2. Interactive Multi-Pattern Regex Search & Replace (Original Old Setup Tool)
  {
    "AckslD/muren.nvim",
    cmd = { "MurenToggle", "MurenOpen", "MurenClose", "MurenFresh", "MurenUnique" },
    keys = {
      { "<leader>R", "<cmd>MurenToggle<CR>", desc = "Muren Multi-Search & Replace" },
      { "<leader>mr", "<cmd>MurenToggle<CR>", desc = "Muren Multi-Search & Replace" },
    },
    opts = {
      create_commands = true,
      filetype_in_preview = true,
      two_step = false,
      all_on_line = true,
      preview = true,
      cwd = false,
      files = "**/*",
      keys = {
        close = "q",
        toggle_side = "<Tab>",
        toggle_options_focus = "<C-o>",
        toggle_option_under_cursor = "<CR>",
        scroll_preview_up = "<Up>",
        scroll_preview_down = "<Down>",
        do_replace = "<CR>",
        do_undo = "<localleader>u",
        do_redo = "<localleader>r",
      },
      patterns_width = 30,
      patterns_height = 10,
      options_width = 20,
      preview_height = 12,
      anchor = "center",
      order = {
        "buffer",
        "dir",
        "files",
        "two_step",
        "all_on_line",
        "preview",
      },
      hl = {
        options = {
          on = "@string",
          off = "@variable.builtin",
        },
        preview = {
          cwd = {
            path = "Comment",
            lnum = "Number",
          },
        },
      },
    },
    config = function(_, opts)
      require("muren").setup(opts)
    end,
  },
}
