-- Code Formatting & Pretty JSON (Conform)
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "PrettyJson" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format Document",
      },
      {
        "<leader>fm",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "Format Document",
      },
      {
        "<leader>pj",
        function()
          vim.cmd("PrettyJson")
        end,
        desc = "Pretty JSON",
      },
    },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_format", "black", stop_after_first = true },
          javascript = { "prettier", stop_after_first = true },
          typescript = { "prettier", stop_after_first = true },
          javascriptreact = { "prettier", stop_after_first = true },
          typescriptreact = { "prettier", stop_after_first = true },
          json = { "jq", "prettier", stop_after_first = true },
          jsonc = { "prettier", stop_after_first = true },
          yaml = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          markdown = { "prettier" },
          sh = { "shfmt" },
          bash = { "shfmt" },
        },
        -- Format on save (can be disabled per buffer if needed)
        format_on_save = function(bufnr)
          -- Disable for specific filetypes if desired
          local ignore_filetypes = { "sql" }
          if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
            return
          end
          return { timeout_ms = 500, lsp_format = "fallback" }
        end,
      })

      -- Dedicated PrettyJson command
      vim.api.nvim_create_user_command("PrettyJson", function()
        if vim.fn.executable("jq") == 1 then
          vim.cmd("%!jq .")
        elseif vim.fn.executable("python3") == 1 then
          vim.cmd("%!python3 -m json.tool")
        else
          conform.format({ formatters = { "prettier" }, lsp_format = "fallback" })
        end
      end, { desc = "Format current buffer as pretty JSON" })
    end,
  },
}
