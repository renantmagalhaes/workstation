return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true, -- This is optional, adjust as needed
      -- Add filesystem component configuration
      filesystem = {
        filtered_items = {
          visible = true, -- Make filtered items visible
          hide_dotfiles = false, -- Show hidden files (dotfiles)
          hide_gitignored = false, -- Optionally, show gitignored files
          hide_by_name = {
            -- Specify any filenames you might want to keep hidden; empty if none
          },
        },
      },
      default_component_configs = {
        -- Component configurations; add if you have specific component configs
      },
    })
    -- The rest of your key mappings and commands
    vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
    vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
    vim.cmd[[
      autocmd VimEnter * Neotree source=filesystem reveal=true
    ]]
  end,
}

