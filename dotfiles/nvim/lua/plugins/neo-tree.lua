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
      close_if_last_window = true, -- optional, adjust as needed
      -- Add filesystem component configuration
      filesystem = {
        filtered_items = {
          visible = true, -- Make filtered items visible
          hide_dotfiles = false, -- Show hidden files (dotfiles)
          hide_gitignored = false, -- Optionally, show gitignored files
          -- Add any specific files or folders you want to hide; empty if none
        },
      },
      -- Configure the window options here
      window = {
        width = 25, -- Set the width of the NeoTree window
        -- You can also set 'position = "left"' or 'position = "right"' if you want to specify which side of the screen NeoTree opens on
      },
    })
    -- Custom keymaps
    vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", {})
    vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", {})
    vim.cmd [[
      autocmd VimEnter * Neotree source=filesystem reveal=true
    ]]
  end,
}

