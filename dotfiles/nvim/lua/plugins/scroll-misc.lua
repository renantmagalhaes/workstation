return {
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup({
        -- excluded_filetypes = { "nerdtree" },
        -- current_only = true,
        -- base = "buffer",
        -- column = 80,
        -- signs_on_startup = { "all" },
        -- diagnostics_severities = { vim.diagnostic.severity.ERROR },
      })
    end,
  },
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("hlslens").setup() -- is not required
      require("scrollbar.handlers.search").setup({
        -- hlslens config overrides
      })
    end,
  },

}
