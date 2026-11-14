-- Automatic Linting for All Languages (nvim-lint)
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")

      -- Detect language / filetype and attach corresponding linters
      lint.linters_by_ft = {
        python = { "ruff", "flake8" },
        javascript = { "eslint_d", "eslint" },
        typescript = { "eslint_d", "eslint" },
        javascriptreact = { "eslint_d", "eslint" },
        typescriptreact = { "eslint_d", "eslint" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        json = { "jsonlint" },
        yaml = { "yamllint" },
        dockerfile = { "hadolint" },
        markdown = { "markdownlint" },
      }

      -- Function that ONLY runs linters if their executable is actually installed
      local function safe_lint()
        local ft = vim.bo.filetype
        local linter_names = lint.linters_by_ft[ft] or {}
        local active_linters = {}

        for _, name in ipairs(linter_names) do
          local linter = lint.linters[name]
          local cmd = name
          if type(linter) == "table" and linter.cmd then
            cmd = linter.cmd
          end
          if type(cmd) == "string" and vim.fn.executable(cmd) == 1 then
            table.insert(active_linters, name)
          end
        end

        if #active_linters > 0 then
          pcall(lint.try_lint, active_linters)
        end
      end

      -- Trigger linting on save and enter safely
      local lint_augroup = vim.api.nvim_create_augroup("LintGroup", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = safe_lint,
      })
    end,
  },
}
