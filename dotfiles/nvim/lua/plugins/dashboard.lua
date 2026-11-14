-- Minimalist & Stable Startup Dashboard (Alpha)
return {
  {
    "goolord/alpha-nvim",
    cmd = { "Alpha", "Dashboard" },
    keys = {
      { "<leader>;", "<cmd>Dashboard<CR>", desc = "Toggle Dashboard" },
      { "<leader>a", "<cmd>Dashboard<CR>", desc = "Toggle Dashboard" },
    },
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
        dashboard.button("s", "  Restore Session", "<cmd>lua require('persistence').load()<CR>"),
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

      -- Smart toggle function: opens dashboard if on a file, returns to file if on dashboard
      local function toggle_dashboard()
        if vim.bo.filetype == "alpha" then
          local alt = vim.fn.bufnr("#")
          if alt > 0 and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
            vim.cmd("buffer #")
            return
          end
          local bufs = vim.tbl_filter(function(b)
            return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and vim.bo[b].filetype ~= "alpha" and vim.bo[b].buftype == ""
          end, vim.api.nvim_list_bufs())
          if #bufs > 0 then
            vim.api.nvim_set_current_buf(bufs[1])
            return
          end
        else
          alpha.start(false, dashboard.config)
        end
      end

      -- User command :Dashboard (toggles back and forth)
      pcall(vim.api.nvim_create_user_command, "Dashboard", toggle_dashboard, { desc = "Toggle Dashboard" })

      -- Disable folding and line numbers on dashboard, and let <Esc> return to previous buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function(event)
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.cursorline = false

          -- Press Esc to quickly return to previous open file buffer
          vim.keymap.set("n", "<Esc>", function()
            local alt = vim.fn.bufnr("#")
            if alt > 0 and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
              vim.cmd("buffer #")
            end
          end, { buffer = event.buf, silent = true, desc = "Return to previous file" })
        end,
      })
    end,
  },
}
