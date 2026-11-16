-- Markdown Support, Live Preview & Paste Image
return {
  -- Rich inline markdown renderer (headings, tables, callouts, checkboxes, code badges)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {
      heading = {
        enabled = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        enabled = true,
        sign = false,
        style = "full",
        width = "block",
      },
      checkbox = {
        enabled = true,
      },
      bullet = {
        enabled = true,
      },
      table = {
        enabled = true,
        style = "full",
      },
    },
  },

  -- Markdown browser preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install && git restore .",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 1
    end,
    ft = { "markdown" },
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Toggle Markdown Preview" },
    },
  },

  -- Paste image from clipboard directly into Markdown files
  {
    "HakonHarnes/img-clip.nvim",
    cmd = "PasteImage",
    ft = { "markdown", "text" },
    -- Buffer-local to markdown/text so <leader>p does not shadow <leader>pj elsewhere
    keys = {
      { "<leader>p", "<cmd>PasteImage<CR>", desc = "Paste Clipboard Image", ft = { "markdown", "text" } },
      { "<leader>P", "<cmd>PasteImage<CR>", desc = "Paste Clipboard Image", ft = { "markdown", "text" } },
    },
    opts = {
      default = {
        dir_path = "assets/images",
        file_name = "%Y-%m-%d-%H-%M-%S",
        use_absolute_path = false,
        relative_to_current_file = true,
        prompt_for_file_name = false,
      },
    },
  },
}
