return {
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({})
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    submodules = false,
    config = function()
      local rb = require("rainbow-delimiters")
      require("rainbow-delimiters.setup").setup({
        strategy = {
          [""] = rb.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
        -- Skip special buffers like terminal, snacks, etc. to avoid "parser nil" error
        condition = function(bufnr)
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
          return buftype == ""
        end,
      })
    end,
  },
}
