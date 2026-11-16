-- Lateral Preview Bar / Minimap (nvim-mini/mini.map)
return {
  {
    "nvim-mini/mini.map",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local map = require("mini.map")

      -- Filetypes that never get their own minimap / spacer
      local excluded_ft = {
        help = true,
        alpha = true,
        dashboard = true,
        ["neo-tree"] = true,
        NvimTree = true,
        lazy = true,
        mason = true,
        trouble = true,
        qf = true,
        TelescopePrompt = true,
        noice = true,
        notify = true,
        ["grug-far"] = true,
        minimap_spacer = true,
      }

      local function is_file_buf(buf)
        return vim.bo[buf].buftype == "" and not excluded_ft[vim.bo[buf].filetype]
      end

      -- Keep the minimap showing the last file while you are in the tree, Telescope, a terminal,
      -- etc. mini.map skips refreshes for buffers with `vim.b.minimap_disable`. Registered before
      -- map.setup() so it runs ahead of mini.map's own BufEnter handler.
      vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "TermOpen" }, {
        group = vim.api.nvim_create_augroup("MiniMapFreeze", { clear = true }),
        callback = function(args)
          if vim.bo[args.buf].filetype == "minimap" then
            return -- mini.map's own buffer (focus mode) must keep working
          end
          vim.b[args.buf].minimap_disable = not is_file_buf(args.buf) or nil
        end,
      })

      map.setup({
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic(),
          map.gen_integration.gitsigns(),
        },
        symbols = {
          -- High-resolution Braille dot matrix ('4x2')
          encode = map.gen_encode_symbols.dot("4x2"),
          scroll_line = "█",
          scroll_view = "┃",
        },
        window = {
          focusable = true,
          side = "right",
          show_integration_count = true,
          width = 16,
          winblend = 10,
          zindex = 30, -- High zindex ensures Sticky Function Header (zindex 20) never blocks the minimap!
        },
      })

      -- Manage dedicated right spacer to limit editor width and keep text from going behind minimap
      local spacer_win = nil
      local spacer_buf = nil
      local is_busy = false

      local function is_spacer_open()
        return spacer_win ~= nil and vim.api.nvim_win_is_valid(spacer_win)
      end

      local function close_spacer()
        if is_spacer_open() and not is_busy then
          is_busy = true
          local w = spacer_win
          spacer_win = nil
          pcall(vim.api.nvim_win_close, w, true)
          is_busy = false
        end
      end

      local function open_spacer()
        if is_spacer_open() or is_busy then
          return
        end
        is_busy = true
        local cur_win = vim.api.nvim_get_current_win()

        if spacer_buf == nil or not vim.api.nvim_buf_is_valid(spacer_buf) then
          spacer_buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_set_option_value("buftype", "nofile", { buf = spacer_buf })
          vim.api.nvim_set_option_value("bufhidden", "hide", { buf = spacer_buf })
          vim.api.nvim_set_option_value("buflisted", false, { buf = spacer_buf })
          vim.api.nvim_set_option_value("swapfile", false, { buf = spacer_buf })
          vim.api.nvim_set_option_value("modifiable", false, { buf = spacer_buf })
          vim.api.nvim_set_option_value("filetype", "minimap_spacer", { buf = spacer_buf })
        end

        vim.cmd("botright vertical 16split")
        spacer_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(spacer_win, spacer_buf)
        vim.api.nvim_set_option_value("winfixwidth", true, { win = spacer_win })
        vim.api.nvim_set_option_value("number", false, { win = spacer_win })
        vim.api.nvim_set_option_value("relativenumber", false, { win = spacer_win })
        vim.api.nvim_set_option_value("foldcolumn", "0", { win = spacer_win })
        vim.api.nvim_set_option_value("signcolumn", "no", { win = spacer_win })
        vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,NormalNC:Normal", { win = spacer_win })

        if vim.api.nvim_win_is_valid(cur_win) then
          vim.api.nvim_set_current_win(cur_win)
        end
        is_busy = false
      end

      -- Automatically open the minimap for normal file buffers
      local minimap_enabled = true

      -- Does the current tabpage still show at least one real file in a regular split?
      local function has_file_window()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if win ~= spacer_win and vim.api.nvim_win_get_config(win).relative == "" then
            if is_file_buf(vim.api.nvim_win_get_buf(win)) then
              return true
            end
          end
        end
        return false
      end

      local function update_minimap_state()
        if not minimap_enabled then
          close_spacer()
          map.close()
          return
        end

        -- Floating windows (Telescope, terminal popup, dialogs, Lazy, ...) never change the layout,
        -- otherwise the whole editor re-flows behind the popup every time one opens.
        if vim.api.nvim_win_get_config(0).relative ~= "" then
          return
        end

        if has_file_window() and vim.o.columns > 80 then
          open_spacer()
          vim.schedule(function()
            pcall(map.open)
          end)
        else
          close_spacer()
          map.close()
        end
      end

      -- Autocommands for opening and closing on buffer/window navigation
      local augroup = vim.api.nvim_create_augroup("MiniMapManager", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "WinClosed" }, {
        group = augroup,
        callback = function()
          if is_busy then
            return
          end
          -- Ignore event if it occurred in the spacer window
          if is_spacer_open() and vim.api.nvim_get_current_win() == spacer_win then
            local normal_wins = 0
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local cfg = vim.api.nvim_win_get_config(win)
              if cfg.relative == "" and win ~= spacer_win then
                normal_wins = normal_wins + 1
              end
            end
            if normal_wins > 0 then
              vim.cmd("wincmd p")
            else
              close_spacer()
            end
            return
          end
          -- WinClosed fires before the window is gone: re-check once it has been removed
          vim.schedule(update_minimap_state)
        end,
      })

      -- Keep spacer at 16 columns when terminal is resized
      vim.api.nvim_create_autocmd("VimResized", {
        group = augroup,
        callback = function()
          if is_spacer_open() then
            pcall(vim.api.nvim_win_set_width, spacer_win, 16)
          end
        end,
      })

      -- Clean up spacer before quitting to prevent lingering window
      vim.api.nvim_create_autocmd("QuitPre", {
        group = augroup,
        callback = close_spacer,
      })

      -- Smart toggle function that bounds editor width when ON and restores full width when OFF
      local function toggle_minimap()
        minimap_enabled = not minimap_enabled
        if minimap_enabled then
          open_spacer()
          map.open()
          vim.notify("Minimap visible (editor bounded to minimap)", vim.log.levels.INFO, { title = "Minimap" })
        else
          map.close()
          close_spacer()
          vim.notify("Minimap hidden (full editor space restored)", vim.log.levels.INFO, { title = "Minimap" })
        end
      end

      -- User command
      vim.api.nvim_create_user_command("MinimapToggle", toggle_minimap, {
        desc = "Toggle lateral preview bar (minimap) and bound editor width",
      })

      -- Keymaps
      vim.keymap.set("n", "<leader>mm", toggle_minimap, { desc = "Toggle Minimap (Bounds Editor)" })
      vim.keymap.set("n", "<leader>um", toggle_minimap, { desc = "Toggle Minimap (Bounds Editor)" })
      vim.keymap.set("n", "<leader>mf", map.toggle_focus, { desc = "Focus/Unfocus Minimap" })
      -- (<leader>mr belongs to muren; use :lua MiniMap.refresh() if ever needed)
    end,
    keys = {
      { "<leader>mm", desc = "Toggle Minimap (Bounds Editor)" },
      { "<leader>um", desc = "Toggle Minimap (Bounds Editor)" },
      { "<leader>mf", desc = "Focus/Unfocus Minimap" },
    },
  },
}
