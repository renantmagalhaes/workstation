-- Fuzzy Search & Pickers (Telescope)
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Telescope",
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_ignore_patterns = { "node_modules", ".git/", "vendor/", "%.lock" },
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
            },
            n = {
              ["q"] = actions.close,
              ["<Esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
          },
          current_buffer_fuzzy_find = {
            previewer = false,
            layout_config = {
              width = 0.7,
              height = 0.6,
            },
          },
        },
      })
    end,
  },
}
