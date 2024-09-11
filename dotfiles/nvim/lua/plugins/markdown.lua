return {
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  --   ft = { "markdown" },
  --   build = function()
  --     vim.fn["mkdp#util#install"]()
  --   end,
  -- },
  {
    "jghauser/follow-md-links.nvim",
    vim.keymap.set("n", "<bs>", ":edit #<cr>", { silent = true }),
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown", -- or 'event = "VeryLazy"'
    opts = {
      -- configuration here or empty for defaults
    },
    config = function()
      require("markdown").setup()
    end,
  },
  {
    "jakewvincent/mkdnflow.nvim",
    config = function()
      require("mkdnflow").setup({
        -- Config goes here; leave blank for defaults
        mappings = {
          MkdnCreateLinkFromClipboard = { { "n", "v" }, "<leader>p" }, -- see MkdnEnter
        },
      })
    end,
  },
  -- {
  --        "lukas-reineke/headlines.nvim",
  --        dependencies = "nvim-treesitter/nvim-treesitter",
  --        config = true, -- or `opts = {}`
  --    },
}
