-- Git Integration (Gitsigns & LazyGit)
return {
  -- Gitsigns for gutter highlights and hunk operations
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local gitsigns = require("gitsigns")

      gitsigns.setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 500,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "   <author>, <author_time:%R> • <summary>",
        on_attach = function(bufnr)
          local map = function(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation between hunks
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gitsigns.nav_hunk("next")
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Next Git Hunk" })

          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gitsigns.nav_hunk("prev")
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Previous Git Hunk" })

          -- Actions
          map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage Hunk" })
          map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset Hunk" })
          map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview Hunk" })
          map("n", "<leader>gb", gitsigns.toggle_current_line_blame, { desc = "Toggle Git Blame Line" })
          map("n", "<leader>hd", gitsigns.diffthis, { desc = "Git Diff" })
        end,
      })
    end,
  },

  -- LazyGit Integration
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },

  -- Side-by-side diff & file history (VS Code Source Control diff view / Timeline)
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      {
        "<leader>gd",
        function()
          if require("diffview.lib").get_current_view() then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Toggle Diff View (all changes)",
      },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "File History (current file)" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<CR>", desc = "Repo History" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = { merge_tool = { layout = "diff3_mixed" } },
    },
  },

  -- Merge conflicts (VS Code "Accept Current / Incoming / Both" CodeLens).
  -- Keys exist only in buffers with conflict markers:
  --   co = ours (current), ct = theirs (incoming), cb = both, c0 = none, ]n / [n = next / prev conflict
  -- Detection needs Neovim's working directory to be the repository root (`nvim .` in the project).
  {
    "akinsho/git-conflict.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("git-conflict").setup({
        default_mappings = {
          ours = "co",
          theirs = "ct",
          both = "cb",
          none = "c0",
          next = "]n", -- not ]x/[x: [x is the sticky-context jump
          prev = "[n",
        },
        -- The plugin's own option calls vim.diagnostic.disable(), removed in Neovim 0.12
        disable_diagnostics = false,
      })
      -- Hide diagnostics while a file has conflict markers (they are all noise until resolved)
      local group = vim.api.nvim_create_augroup("GitConflictDiagnostics", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "GitConflictDetected",
        callback = function()
          vim.diagnostic.enable(false, { bufnr = 0 })
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "GitConflictResolved",
        callback = function()
          vim.diagnostic.enable(true, { bufnr = 0 })
        end,
      })
    end,
  },

  -- Tim Pope's Fugitive for Git commands
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
  },
}
