return {
 {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
    require("barbar").setup()
    end,
    vim.keymap.set('n', '<A-,>', ':BufferPrevious<CR>'),
    vim.keymap.set('n', '<A-.>', ':BufferNext<CR>')
  },
}
