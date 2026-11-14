-- Minimalist & Stable Startup Dashboard (Alpha)
return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Sleek, minimalist header
      dashboard.section.header.val = {
        [[        _   __                _            ]],
        [[       / | / /___  ____ _   _(_)___ ___    ]],
        [[      /  |/ / _ \/ __ \ | / / / __ `__ \   ]],
        [[     / /|  /  __/ /_/ / |/ / / / / / / /   ]],
        [[    /_/ |_/\___/\____/|___/_/_/ /_/ /_/    ]],
      }

      -- Header highlight
      dashboard.section.header.opts.hl = "Keyword"

      -- Quick Action Buttons
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find File", "<cmd>Telescope find_files hidden=true<CR>"),
        dashboard.button("r", "  Recent Files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Find Text (Grep)", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("e", "  File Explorer", "<cmd>NvimTreeToggle<CR>"),
        dashboard.button("n", "  New File", "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("q", "  Quit", "<cmd>confirm qa<CR>"),
      }

      -- Shortcut key highlight
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl_shortcut = "Number"
      end

      -- Footer
      local datetime = os.date(" %Y-%m-%d   %H:%M")
      dashboard.section.footer.val = { datetime, "", "⚡ Ready to build" }
      dashboard.section.footer.opts.hl = "Comment"

      -- Layout padding
      dashboard.config.layout = {
        { type = "padding", val = 4 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 2 },
        dashboard.section.footer,
      }

      alpha.setup(dashboard.config)

      -- Disable folding and line numbers on dashboard
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.cursorline = false
        end,
      })
    end,
  },
}
