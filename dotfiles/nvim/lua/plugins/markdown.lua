return {
  {
    -- Install markdown preview, use npx if available.
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function(plugin)
      if vim.fn.executable("npx") then
        vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
      else
        vim.cmd([[Lazy load markdown-preview.nvim]])
        vim.fn["mkdp#util#install"]()
      end
    end,
    init = function()
      if vim.fn.executable("npx") then
        vim.g.mkdp_filetypes = { "markdown" }
      end
    end,
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
