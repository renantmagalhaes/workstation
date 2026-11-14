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

      -- Non-code and plain text filetypes that should NEVER trigger tree-sitter
      local ignored_filetypes = {
        [""] = true,
        text = true,
        txt = true,
        plain = true,
        log = true,
        help = true,
        man = true,
        qf = true,
        gitcommit = true,
        gitrebase = true,
        netrw = true,
        NvimTree = true,
        alpha = true,
        trouble = true,
        lazy = true,
        mason = true,
        checkhealth = true,
        prompt = true,
      }

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
          if ignored_filetypes[ft] then
            return
          end

          local lang = vim.treesitter.language.get_lang(ft) or ft
          if not lang or ignored_filetypes[lang] then
            return
          end

          -- Start tree-sitter highlighting safely with pcall
          local started = pcall(vim.treesitter.start, bufnr)
          -- If not started (parser not installed yet), only install if actually supported by Treesitter
          if not started then
            local ok_avail, available = pcall(ts.get_available)
            if ok_avail and type(available) == "table" and vim.tbl_contains(available, lang) then
              pcall(ts.install, { lang })
            end
          end
        end,
      })
    end,
  },
}
