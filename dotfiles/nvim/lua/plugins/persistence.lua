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

      -- 1. Auto-restore session on startup (VS Code behavior)
      -- Triggers when nvim is opened without concrete file arguments (e.g. `nvim` or `nvim .`)
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("PersistenceAutoRestore", { clear = true }),
        nested = true,
        callback = function()
          local opened_real_file = false
          for _, arg in ipairs(vim.fn.argv()) do
            if arg ~= "" and vim.fn.filereadable(arg) == 1 and vim.fn.isdirectory(arg) == 0 then
              opened_real_file = true
              break
            end
          end

          if not opened_real_file and not vim.g.started_by_firenvim then
            local session_file = persistence.current()
            if vim.fn.filereadable(session_file) == 0 then
              session_file = persistence.current({ branch = false })
            end
            if vim.fn.filereadable(session_file) == 1 then
              persistence.load()
            end
          end
        end,
      })

      -- 2. Guard: Never save a session if NO real files are open
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
