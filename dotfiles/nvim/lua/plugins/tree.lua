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
    end,
  },
}
