return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install && git restore .",
    -- or if you use yarn: (I have not checked this, I use npm)
    -- build = "cd app && yarn install && git restore .",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
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
