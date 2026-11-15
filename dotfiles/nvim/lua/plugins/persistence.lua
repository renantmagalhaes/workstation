-- Session Management & Workspace Restoration
return {
  {
    "folke/persistence.nvim",
    lazy = false, -- Load immediately so it can auto-restore sessions on startup
    opts = {
      need = 1,
      branch = false, -- Keep session per project directory
    },
    config = function(_, opts)
      local persistence = require("persistence")
      persistence.setup(opts)

      -- Recommended sessionoptions
      vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }

      -- Guard: Never save a session if NO real files are open
      -- Prevents an empty directory or file tree open from wiping out previous work
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        callback = function()
          local has_real_file = false
          for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "" then
              local name = vim.api.nvim_buf_get_name(b)
              if name ~= "" and vim.fn.filereadable(name) == 1 and vim.fn.isdirectory(name) == 0 then
                has_real_file = true
                break
              end
            end
          end
          if not has_real_file then
            persistence.stop()
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session (Current Directory)",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
}
