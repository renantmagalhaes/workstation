-- Multi-Cursor & Multi-Line Editing (VS Code Style)
return {
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local map = vim.keymap.set

      -- 1. Multi-Line Visual Editing (The classic VS Code selection workflow):
      -- Highlight multiple lines in Visual mode and press:
      --   'I' -> insert simultaneously at the start of every selected line
      --   'A' -> append simultaneously at the end of every selected line
      --   '<leader>m' -> convert visual selection into multiple cursors
      map("x", "I", mc.insertVisual, { desc = "Insert across all selected lines" })
      map("x", "A", mc.appendVisual, { desc = "Append across all selected lines" })
      map("x", "<leader>m", mc.visualToCursors, { desc = "Convert selection to multi-cursors" })

      -- 2. Add Cursors Vertically (Up / Down):
      local add_cursor_down = function() mc.lineAddCursor(1) end
      local add_cursor_up = function() mc.lineAddCursor(-1) end

      -- Standard keys & foolproof terminal/tmux shortcuts:
      map({ "n", "x" }, "<C-Down>", add_cursor_down, { desc = "Add cursor below" })
      map({ "n", "x" }, "<C-Up>", add_cursor_up, { desc = "Add cursor above" })
      map({ "n", "x" }, "<M-Down>", add_cursor_down, { desc = "Add cursor below" })
      map({ "n", "x" }, "<M-Up>", add_cursor_up, { desc = "Add cursor above" })
      map({ "n", "x" }, "<leader>j", add_cursor_down, { desc = "Add cursor below" })
      map({ "n", "x" }, "<leader>k", add_cursor_up, { desc = "Add cursor above" })

      -- Raw ANSI escape codes for tmux (screen-256color) when Ctrl-Up/Down is sent:
      map({ "n", "x" }, "\27[1;5B", add_cursor_down, { desc = "Add cursor below (tmux Ctrl+Down)" })
      map({ "n", "x" }, "\27[1;5A", add_cursor_up, { desc = "Add cursor above (tmux Ctrl+Up)" })
      map({ "n", "x" }, "\27[1;3B", add_cursor_down, { desc = "Add cursor below (tmux Alt+Down)" })
      map({ "n", "x" }, "\27[1;3A", add_cursor_up, { desc = "Add cursor above (tmux Alt+Up)" })

      -- Skip line up/down without adding cursor
      map({ "n", "x" }, "<leader><Down>", function() mc.lineSkipCursor(1) end, { desc = "Skip cursor down" })
      map({ "n", "x" }, "<leader><Up>", function() mc.lineSkipCursor(-1) end, { desc = "Skip cursor up" })

      -- 3. Match Word under Cursor (VS Code Ctrl+D / Ctrl+Shift+L):
      -- <C-n>, <A-d>, or <leader>m adds cursor at next matching word
      local match_next = function() mc.matchAddCursor(1) end
      map({ "n", "x" }, "<C-n>", match_next, { desc = "Add cursor at next match" })
      map({ "n", "x" }, "<M-d>", match_next, { desc = "Add cursor at next match" })
      map({ "n", "x" }, "<leader>m", match_next, { desc = "Add cursor at next match" })
      map({ "n", "x" }, "<leader>M", function() mc.matchSkipCursor(1) end, { desc = "Skip next match" })
      map({ "n", "x" }, "<leader>A", mc.matchAllAddCursors, { desc = "Add cursors to all matches" })

      -- 4. Mouse Multi-Cursor (VS Code Ctrl+Click):
      map("n", "<C-LeftMouse>", mc.handleMouse, { desc = "Add or remove cursor on click" })
      map("n", "<C-LeftDrag>", mc.handleMouseDrag, { desc = "Drag multiple cursors" })
      map("n", "<C-LeftRelease>", mc.handleMouseRelease, { desc = "Release cursor drag" })

      -- 5. Toggle Cursors
      map({ "n", "x" }, "<C-q>", mc.toggleCursor, { desc = "Toggle multiple cursors" })

      -- 6. Keymap Layer: Active ONLY when multiple cursors exist
      mc.addKeymapLayer(function(layerSet)
        -- Left/Right arrows cycle through active cursors
        layerSet({ "n", "x" }, "<Left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<Right>", mc.nextCursor)

        -- Delete current main cursor
        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Pressing Esc clears all extra cursors and returns to single cursor
        layerSet("n", "<Esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          elseif mc.hasCursors() then
            mc.clearCursors()
          end
        end)
      end)

      -- 7. Visual Highlights
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { link = "Cursor" })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
      hl(0, "MultiCursorDisabledVisual", { link = "Comment" })
    end,
  },
}
