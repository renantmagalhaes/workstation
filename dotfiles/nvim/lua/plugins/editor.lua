-- Editor Ergonomics (Autopairs, Comments, Surround, Colorizer, Rainbow Delimiters)
return {
  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
        },
      })
      -- Integrate with cmp if cmp is present
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp_status, cmp = pcall(require, "cmp")
      if cmp_status then
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },

  -- Commenting (gcc / gc)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- Surround (ysiw", cs"', ds")
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Colorizer (Show inline hex/rgb colors)
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = false,
          RRGGBBAA = true,
          AARRGGBB = true,
          rgb_fn = true,
          hsl_fn = true,
          css = true,
          css_fn = true,
          mode = "background",
          tailwind = true,
        },
      })
    end,
  },

  -- Rainbow Delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
  },
}
