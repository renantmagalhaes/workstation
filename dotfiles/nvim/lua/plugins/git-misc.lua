return {
  {
    "tpope/vim-fugitive",
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
      })
      require("scrollbar.handlers.gitsigns").setup()
      vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", {})
      vim.keymap.set("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", {})
    end,
  },
  -- {
  --   "f-person/git-blame.nvim",
  --   -- load the plugin at startup
  --   event = "VeryLazy",
  --   -- Because of the keys part, you will be lazy loading this plugin.
  --   -- The plugin wil only load once one of the keys is used.
  --   -- If you want to load the plugin at startup, add something like event = "VeryLazy",
  --   -- or lazy = false. One of both options will work.
  --   opts = {
  --     -- your configuration comes here
  --     -- for example
  --     enabled = true, -- if you want to enable the plugin
  --     message_template = " <summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
  --     date_format = "%m-%d-%Y %H:%M:%S", -- template for the date, check Date format section for more options
  --     virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
  --   },
  -- },
}
