-- Automatic Syntax Highlighting (Treesitter for Neovim 0.12+)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- Modern main branch required for Neovim 0.12+
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter")
      if not ok then
        return
      end

      -- Initialize treesitter
      ts.setup()

      -- Core languages to ensure installed
      local parsers = {
        "bash",
        "c",
        "css",
        "dockerfile",
        "go",
        "html",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "sql",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }

      pcall(ts.install, parsers)

      -- Enable native Neovim 0.12+ tree-sitter highlighting on-demand
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterNativeHighlight", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          -- Ignore non-file buffers, special buffers, netrw, and file trees
          if vim.bo[bufnr].buftype ~= "" then
            return
          end

          local ft = vim.bo[bufnr].filetype
          if ft == "" or ft == "netrw" or ft == "NvimTree" then
            return
          end

          -- Start tree-sitter highlighting safely with pcall
          local started = pcall(vim.treesitter.start, bufnr)
          -- If not started (parser not installed yet), install it on-demand in the background
          if not started then
            local lang = vim.treesitter.language.get_lang(ft) or ft
            pcall(ts.install, { lang })
          end
        end,
      })
    end,
  },
}
