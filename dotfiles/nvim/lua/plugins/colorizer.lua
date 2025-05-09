return {
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({})
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      submodules = false, require("rainbow-delimiters.setup").setup({})
    end,
  },
}
