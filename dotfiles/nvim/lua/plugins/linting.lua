-- Automatic Linting for All Languages (nvim-lint)
return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")

      -- Per filetype: a list of ALTERNATIVES in order of preference. Only the first one that is
      -- actually installed runs, so e.g. ruff and flake8 never report the same issue twice.
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

      -- Resolve a linter's executable. nvim-lint defines some linters as functions, and some
      -- `cmd`s as functions (eslint/eslint_d prefer ./node_modules/.bin), so evaluate both.
      local function linter_cmd(name)
        local ok, linter = pcall(function()
          return lint.linters[name]
        end)
        if not ok then
          return nil
        end
        if type(linter) == "function" then
          ok, linter = pcall(linter)
          if not ok then
            return nil
          end
        end
        local cmd = type(linter) == "table" and linter.cmd or name
        if type(cmd) == "function" then
          ok, cmd = pcall(cmd)
          if not ok then
            return nil
          end
        end
        return type(cmd) == "string" and cmd or nil
      end

      -- Run the first installed linter for the current buffer's filetype
      local function safe_lint()
        if vim.bo.buftype ~= "" then
          return
        end
        for _, name in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
          local cmd = linter_cmd(name)
          if cmd and vim.fn.executable(cmd) == 1 then
            pcall(lint.try_lint, name)
            return
          end
        end
      end

      -- Trigger linting on save and enter safely
      local lint_augroup = vim.api.nvim_create_augroup("LintGroup", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = safe_lint,
      })

      -- The plugin loads on the first BufReadPost, possibly before filetype detection ran and
      -- after BufEnter already fired: lint the initial buffer once the event loop settles
      vim.schedule(safe_lint)
    end,
  },
}
