-- Lateral File Tree (NvimTree)
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false, -- Eager load so it hijacks directory openings (e.g. `nvim .`)
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Tree" },
      { "<C-b>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Tree (VS Code)" },
      { "<leader>o", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal File in Tree" },
    },
    config = function()
      -- Renaming / moving a file in the tree (F2, r, cut + paste) asks the language servers to
      -- update imports that point at it, like VS Code's explorer
      local api = require("nvim-tree.api")
      -- nvim-tree re-saves open buffers under their new name (`write!`); don't run format-on-save
      -- for that, the language server hasn't seen the new path yet and returns an error
      api.events.subscribe(api.events.Event.WillRenameNode, function(data)
        require("config.lsp_rename").before_rename(data.old_name, data.new_name)
        vim.g.skip_format_on_save = true
        vim.schedule(function() -- the rename runs synchronously, so this clears right after it
          vim.g.skip_format_on_save = nil
        end)
      end)
      api.events.subscribe(api.events.Event.NodeRenamed, function(data)
        require("config.lsp_rename").on_rename(data.old_name, data.new_name)
      end)

      require("nvim-tree").setup({
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          -- VS Code explorer: F2 renames the file/folder under the cursor (same as `r`)
          vim.keymap.set(
            "n",
            "<F2>",
            api.fs.rename,
            { buffer = bufnr, nowait = true, silent = true, desc = "nvim-tree: Rename" }
          )
        end,
        disable_netrw = true,
        hijack_netrw = true,
        hijack_directories = { enable = false },
        hijack_cursor = true,
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          width = 34,
          side = "left",
          preserve_window_proportions = true,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        renderer = {
          highlight_git = true,
          highlight_opened_files = "none",
          root_folder_label = ":~:s?$?/..?",
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
          },
        },
        filters = {
          dotfiles = false,
          custom = { "^.git$" },
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
            window_picker = {
              enable = false,
            },
          },
        },
      })

      -- Automatically open nvim-tree sidebar when opening a file (e.g. `nvim .` -> select file, or `nvim file`)
      local tree_opened_on_file = false

      -- Reset when returning to dashboard so selecting another file re-opens the tree
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function()
          tree_opened_on_file = false
        end,
      })

      local function open_tree_silently()
        vim.schedule(function()
          local tree_api = require("nvim-tree.api")
          if not tree_api.tree.is_visible() then
            local cur_win = vim.api.nvim_get_current_win()
            tree_api.tree.open({ find_file = true })
            if vim.api.nvim_win_is_valid(cur_win) then
              vim.api.nvim_set_current_win(cur_win)
            end
          end
        end)
      end

      vim.api.nvim_create_autocmd({ "BufWinEnter", "BufReadPost" }, {
        group = vim.api.nvim_create_augroup("NvimTreeAutoOpenFile", { clear = true }),
        callback = function(args)
          if tree_opened_on_file then
            return
          end

          local buf = args.buf
          if not vim.api.nvim_buf_is_valid(buf) then
            return
          end

          local name = vim.api.nvim_buf_get_name(buf)
          local bt = vim.bo[buf].buftype
          local ft = vim.bo[buf].filetype

          -- Skip special and UI buffers
          if bt ~= "" or ft == "alpha" or ft == "NvimTree" or ft == "lazy" or ft == "mason" or ft == "trouble" or ft == "help" then
            return
          end

          -- Only trigger for real files on disk or newly named files
          if name ~= "" and vim.fn.isdirectory(name) == 0 then
            tree_opened_on_file = true
            open_tree_silently()
          end
        end,
      })
    end,
  },
}
