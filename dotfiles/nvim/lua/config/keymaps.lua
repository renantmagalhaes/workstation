-- Keymaps configuration
-- Plugin-specific keys live in their plugin spec (lua/plugins/*.lua); this file holds global
-- editor keys only, so every key has exactly one owner.
local map = vim.keymap.set

-- Neovim 0.11+ ships default LSP maps starting with `gr` (grr, grn, gra, gri, grt, grx).
-- They turn our `gr` (Find References) into a prefix that waits 'timeoutlen'. The same actions
-- are available on F2 / F12 / Shift+F12 / <leader>rn / <leader>ca, so drop the defaults.
for _, lhs in ipairs({ "grr", "grn", "gri", "grt", "grx" }) do
  pcall(vim.keymap.del, "n", lhs)
end
pcall(vim.keymap.del, { "n", "x" }, "gra")

-- ==========================================
-- Core Requested Keymaps
-- ==========================================

-- Save with Ctrl+s (Normal, Insert, Visual)
map("n", "<C-s>", "<cmd>write<CR>", { desc = "Save file", silent = true })
map("i", "<C-s>", "<Esc><cmd>write<CR>a", { desc = "Save file", silent = true })
map("v", "<C-s>", "<Esc><cmd>write<CR>gv", { desc = "Save file", silent = true })

-- Exit with Ctrl+d (Shows a sleek modal dialog box if unsaved changes exist)
local function confirm_exit()
  -- Only real file buffers count: scratch/nofile buffers (grug-far, muren, ...) never block :qa
  local modified, unnamed = {}, 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local bt = vim.bo[buf].buftype
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified and (bt == "" or bt == "acwrite") then
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then
        unnamed = unnamed + 1
      end
      table.insert(modified, (name ~= "") and vim.fn.fnamemodify(name, ":t") or "[Untitled]")
    end
  end

  if #modified == 0 then
    -- No unsaved changes, exit immediately
    vim.cmd("qa")
    return
  end

  -- Display a clean centered dialog box (not a list)
  local files_str = table.concat(modified, ", ")
  if #files_str > 44 then
    files_str = files_str:sub(1, 41) .. "..."
  end

  local function save_and_quit()
    if unnamed > 0 then
      vim.notify(
        "Untitled buffer has no file name. Save it with :w <name>, or choose [No] to discard.",
        vim.log.levels.WARN,
        { title = "Unsaved Changes" }
      )
      return
    end
    local ok, err = pcall(vim.cmd, "wa")
    if not ok then
      vim.notify(tostring(err), vim.log.levels.ERROR, { title = "Save failed" })
      return
    end
    vim.cmd("qa")
  end

  local buttons = {
    { text = "[ Yes ]", action = save_and_quit },
    { text = "[ No ]", action = function() vim.cmd("qa!") end },
    { text = "[ Cancel ]", action = nil },
  }

  local current_idx = 1
  local width = 58
  local prompt_line = "  Save changes before quitting?"
  local mod_line = "  Modified: " .. files_str
  local hint_line = "        y: save & quit  •  n: discard  •  esc: cancel"

  local content_lines = {
    "",
    prompt_line,
    mod_line,
    "",
    "", -- Button row placeholder (line index 5)
    "",
    hint_line,
    "",
  }

  local btn_row = 5
  local height = #content_lines

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = " 󰈆  Unsaved Changes ",
    title_pos = "center",
  })

  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
  vim.wo[win].cursorline = false

  local ns = vim.api.nvim_create_namespace("exit_dialog")
  local btn_ranges = {}

  -- Highlight [start_col, end_col) on a 0-based row; end_col = nil means end of line
  local function hl(group, lnum, start_col, end_col)
    local line = vim.api.nvim_buf_get_lines(buf, lnum, lnum + 1, false)[1] or ""
    vim.api.nvim_buf_set_extmark(buf, ns, lnum, start_col, {
      end_col = math.min(end_col or #line, #line),
      hl_group = group,
    })
  end

  local function close_dialog()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function render()
    btn_ranges = {}
    local rendered_buttons = {}
    for i, btn in ipairs(buttons) do
      if i == current_idx then
        table.insert(rendered_buttons, "▶ " .. btn.text .. " ◀")
      else
        table.insert(rendered_buttons, "  " .. btn.text .. "  ")
      end
    end

    local total_len = 0
    for _, b in ipairs(rendered_buttons) do
      total_len = total_len + #b
    end

    local gap = math.max(2, math.floor((width - total_len) / (#buttons + 1)))
    local pad = string.rep(" ", gap)
    local btn_line = pad .. table.concat(rendered_buttons, pad)

    local extra = width - #btn_line
    if extra > 0 then
      btn_line = string.rep(" ", math.floor(extra / 2)) .. btn_line
    end

    local search_pos = 1
    for i, btn in ipairs(buttons) do
      local tag = (i == current_idx) and ("▶ " .. btn.text .. " ◀") or ("  " .. btn.text .. "  ")
      local s, e = btn_line:find(tag, search_pos, true)
      if s and e then
        table.insert(btn_ranges, { start_col = s, end_col = e, idx = i })
        search_pos = e + 1
      end
    end

    content_lines[btn_row] = btn_line

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content_lines)
    vim.bo[buf].modifiable = false

    -- Highlights
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    hl("Title", 1, 2)
    hl("WarningMsg", 2, 2)
    hl("Comment", 6, 0)

    for i, r in ipairs(btn_ranges) do
      hl(i == current_idx and "IncSearch" or "Visual", btn_row - 1, r.start_col - 1, r.end_col)
    end
  end

  render()

  local function execute_current()
    local action = buttons[current_idx].action
    close_dialog()
    if action then
      action()
    end
  end

  local key_opts = { buffer = buf, nowait = true, silent = true }
  local function prev_btn()
    current_idx = (current_idx == 1) and #buttons or (current_idx - 1)
    render()
  end
  local function next_btn()
    current_idx = (current_idx == #buttons) and 1 or (current_idx + 1)
    render()
  end

  -- Instant hotkeys
  for _, k in ipairs({ "y", "Y" }) do
    vim.keymap.set("n", k, function() close_dialog(); buttons[1].action() end, key_opts)
  end
  for _, k in ipairs({ "n", "N" }) do
    vim.keymap.set("n", k, function() close_dialog(); buttons[2].action() end, key_opts)
  end
  for _, k in ipairs({ "c", "C", "q", "<Esc>", "<C-c>" }) do
    vim.keymap.set("n", k, close_dialog, key_opts)
  end

  -- Navigation
  for _, k in ipairs({ "<Left>", "h", "<S-Tab>" }) do
    vim.keymap.set("n", k, prev_btn, key_opts)
  end
  for _, k in ipairs({ "<Right>", "l", "<Tab>" }) do
    vim.keymap.set("n", k, next_btn, key_opts)
  end

  vim.keymap.set("n", "<CR>", execute_current, key_opts)
  vim.keymap.set("n", "<Space>", execute_current, key_opts)

  -- Mouse click support
  vim.keymap.set("n", "<LeftMouse>", function()
    local mouse = vim.fn.getmousepos()
    if mouse.winid == win and mouse.line == btn_row then
      for _, r in ipairs(btn_ranges) do
        if mouse.column >= r.start_col and mouse.column <= r.end_col then
          current_idx = r.idx
          execute_current()
          return
        end
      end
    elseif mouse.winid ~= win then
      close_dialog()
    end
  end, key_opts)
end

map({ "n", "i", "v" }, "<C-d>", function()
  local mode = vim.fn.mode()
  if mode:find("i") then
    vim.cmd("stopinsert")
  elseif mode:find("v") or mode:find("V") or mode == "\22" then
    vim.cmd([[execute "normal! \<ESC>"]])
  end
  confirm_exit()
end, { desc = "Exit with save dialog box", silent = true })

-- Fuzzy search inline (Ctrl+f)
map("n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search inside buffer", silent = true })
map("i", "<C-f>", "<Esc><cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search inside buffer", silent = true })
map("n", "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Search inside buffer", silent = true })

-- Quick Open (VS Code Ctrl+P) & fuzzy search across whole folder (Space Space)
map("n", "<C-p>", "<cmd>Telescope find_files hidden=true<CR>", { desc = "Quick Open file (VS Code Ctrl+P)", silent = true })
map("n", "<leader><leader>", "<cmd>Telescope find_files hidden=true<CR>", { desc = "Find files in project", silent = true })

-- Grep across whole folder / project
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep across project", silent = true })
map("n", "<leader>/", "<cmd>Telescope live_grep<CR>", { desc = "Live grep across project", silent = true })

-- Additional Telescope pickers
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find open buffers", silent = true })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files", silent = true })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags", silent = true })

-- Go to Symbol (VS Code Ctrl+Shift+O in the file, Ctrl+T in the workspace; terminals can't send
-- Ctrl+Shift+O, and Ctrl+T stays Vim's "jump back" after F12)
map("n", "<leader>fo", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Go to symbol in file", silent = true })
map("n", "<leader>fw", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "Go to symbol in workspace", silent = true })

-- Command Palette (VS Code style command fuzzy-finder)
map("n", "<leader>:", "<cmd>Telescope commands<CR>", { desc = "Command Palette", silent = true })
map("n", "<leader>cp", "<cmd>Telescope commands<CR>", { desc = "Command Palette (VS Code Ctrl+Shift+P)", silent = true })
map("n", "<leader>ch", "<cmd>Telescope command_history<CR>", { desc = "Command History", silent = true })

-- Git Web Browser & Link Copy (:GitBrowse, :GitCopyUrl, <leader>go, <leader>gy)
local git_web = require("config.git_web")

vim.api.nvim_create_user_command("GitBrowse", function(args)
  git_web.open({ range = args.range > 0, line1 = args.line1, line2 = args.line2 })
end, { range = true, desc = "Open current file in Git Web browser" })

vim.api.nvim_create_user_command("GitCopyUrl", function(args)
  git_web.copy({ range = args.range > 0, line1 = args.line1, line2 = args.line2 })
end, { range = true, desc = "Copy Git Web URL for current file to clipboard" })

pcall(vim.api.nvim_create_user_command, "GBrowse", function(args)
  git_web.open({ range = args.range > 0, line1 = args.line1, line2 = args.line2 })
end, { range = true, desc = "Open current file in Git Web browser" })

map("n", "<leader>go", function() git_web.open() end, { desc = "Open file in Git Web", silent = true })
map("v", "<leader>go", function()
  vim.cmd([[execute "normal! \<ESC>"]])
  git_web.open({ visual = true })
end, { desc = "Open selected lines in Git Web", silent = true })

map("n", "<leader>gy", function() git_web.copy() end, { desc = "Copy Git Web URL", silent = true })
map("v", "<leader>gy", function()
  vim.cmd([[execute "normal! \<ESC>"]])
  git_web.copy({ visual = true })
end, { desc = "Copy Git Web URL for selected lines", silent = true })

-- ==========================================
-- VS Code-Style & Everyday Ergonomics
-- ==========================================

-- Select all (<C-a>)
map("n", "<C-a>", "ggVG", { desc = "Select all", silent = true })
map("i", "<C-a>", "<Esc>ggVG", { desc = "Select all", silent = true })

-- Redo with U
map("n", "U", "<C-r>", { desc = "Redo", noremap = true })

-- Clear search highlight on Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })

-- Clipboard copy & paste
map("i", "<C-c>", '<cmd>normal! "+yy<CR>', { desc = "Copy line (stay in insert mode)", silent = true })
map("i", "<C-v>", "<C-r>+", { desc = "Paste in insert mode", silent = true })
map("x", "<C-c>", '"+y', { desc = "Copy selection", silent = true })
-- Visual-mode `P` replaces the selection without clobbering the register (also correct at end of line)
map("x", "<C-v>", '"+P', { desc = "Paste replacing selection", silent = true })

-- Move lines up/down (VS Code Alt+Up / Alt+Down; Alt+j / Alt+k also work) in every mode
for _, keys in ipairs({ { "<A-j>", "<A-k>" }, { "<A-Down>", "<A-Up>" } }) do
  local down, up = keys[1], keys[2]
  map("n", down, "<cmd>execute 'move .+' . v:count1<CR>==", { desc = "Move line down", silent = true })
  map("n", up, "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = "Move line up", silent = true })
  map("i", down, "<Esc><cmd>move .+1<CR>==gi", { desc = "Move line down", silent = true })
  map("i", up, "<Esc><cmd>move .-2<CR>==gi", { desc = "Move line up", silent = true })
  map("x", down, ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", { desc = "Move selection down", silent = true })
  map("x", up, ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", { desc = "Move selection up", silent = true })
end

-- Toggle line comment (VS Code Ctrl+/). Terminals send Ctrl+/ as <C-_>, so map both.
local function comment_line()
  require("Comment.api").toggle.linewise.current()
end
local function comment_selection()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
  vim.cmd("normal! gv") -- keep the selection, like VS Code
end
for _, lhs in ipairs({ "<C-/>", "<C-_>" }) do
  map({ "n", "i" }, lhs, comment_line, { desc = "Toggle comment", silent = true })
  map("x", lhs, comment_selection, { desc = "Toggle comment", silent = true })
end

-- Indent / Outdent in Visual mode (Tab / Shift-Tab). `x` (not `v`) so snippet select-mode Tab still jumps.
map("x", "<Tab>", ">gv", { desc = "Indent selection", silent = true })
map("x", "<S-Tab>", "<gv", { desc = "Outdent selection", silent = true })

-- Buffer navigation (tabs at top)
map("n", "[b", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer", silent = true })
map("n", "]b", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer", silent = true })
-- Close buffer but keep the window layout (no collapse into the file tree)
local function close_buffer()
  require("snacks").bufdelete()
end
map("n", "<leader>bd", close_buffer, { desc = "Close buffer", silent = true })
map("n", "<leader>bc", close_buffer, { desc = "Close buffer", silent = true })

-- Quick jump to tabs 1-9
for i = 1, 9 do
  map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i, silent = true })
end

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window", silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Focus lower window", silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Focus upper window", silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window", silent = true })

-- Window splits
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertically", silent = true })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally", silent = true })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal", silent = true })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split", silent = true })

-- Diagnostics (Trouble keys live in lua/plugins/ui.lua)
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic", silent = true })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic", silent = true })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics popup", silent = true })

-- Toggle inlay hints (inline types / parameter names) for the current buffer
map("n", "<leader>uh", function()
  local on = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(not on, { bufnr = 0 })
  vim.notify("Inlay hints " .. (on and "off" or "on"), vim.log.levels.INFO)
end, { desc = "Toggle inlay hints", silent = true })

-- VS Code F2 / F12. Global (not set on LspAttach) so they also work where no language server is
-- attached yet: F2 then renames the word in the current file, F12 falls back to Vim's `gd`.
local function lsp_supports(method)
  return #vim.lsp.get_clients({ bufnr = 0, method = method }) > 0
end

map("n", "<F2>", function()
  if lsp_supports("textDocument/rename") then
    return vim.lsp.buf.rename()
  end
  if not vim.bo.modifiable or vim.bo.readonly then
    return vim.notify("Nothing to rename here (buffer is read-only)", vim.log.levels.WARN)
  end
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return vim.notify("Nothing to rename", vim.log.levels.WARN)
  end
  vim.ui.input({ prompt = "Rename in file (no LSP)", default = word }, function(new)
    if not new or new == "" or new == word then
      return
    end
    local view = vim.fn.winsaveview()
    local pattern = "\\V\\<" .. vim.fn.escape(word, "/\\") .. "\\>"
    local ok, err = pcall(vim.cmd, ("keeppatterns %%s/%s/%s/geI"):format(pattern, vim.fn.escape(new, "/\\&~")))
    vim.fn.winrestview(view)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end)
end, { desc = "Rename symbol (F2)", silent = true })

map("n", "<F12>", function()
  if lsp_supports("textDocument/definition") then
    return vim.lsp.buf.definition()
  end
  vim.cmd("normal! gd")
end, { desc = "Go to definition (F12)", silent = true })

-- Floating Terminal Toggle (<Ctrl+\> or <leader>tt)
local term_state = {
  buf = -1,
  win = -1,
}

local function toggle_floating_terminal()
  if vim.api.nvim_win_is_valid(term_state.win) then
    vim.api.nvim_win_hide(term_state.win)
    return
  end

  local new_term = not vim.api.nvim_buf_is_valid(term_state.buf)
  if new_term then
    term_state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[term_state.buf].buflisted = false
  end

  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.80)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  term_state.win = vim.api.nvim_open_win(term_state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
    title = "   Terminal ",
    title_pos = "center",
  })
  vim.wo[term_state.win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"

  if new_term then
    local buf = term_state.buf
    vim.fn.jobstart({ vim.o.shell }, {
      term = true,
      -- When the shell exits, close the popup and drop the dead buffer so the next toggle starts fresh
      on_exit = function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(term_state.win) and vim.api.nvim_win_get_buf(term_state.win) == buf then
            vim.api.nvim_win_close(term_state.win, true)
          end
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end)
      end,
    })
    -- Terminal-local keys (kept buffer-local so LazyGit & other terminals get an instant <Esc>)
    local topts = { buffer = buf, silent = true }
    vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", vim.tbl_extend("force", topts, { desc = "Exit terminal insert mode" }))
    vim.keymap.set("t", "<C-\\>", toggle_floating_terminal, vim.tbl_extend("force", topts, { desc = "Toggle Floating Terminal" }))
    vim.keymap.set("n", "<C-\\>", toggle_floating_terminal, vim.tbl_extend("force", topts, { desc = "Toggle Floating Terminal" }))
  end

  vim.cmd("startinsert")
end

-- VS Code uses Ctrl+` for the terminal, but most terminals cannot send it; Ctrl+\ is the reliable stand-in.
map({ "n", "i" }, "<C-\\>", toggle_floating_terminal, { desc = "Toggle Floating Terminal", silent = true })
map({ "n", "i" }, "<C-`>", toggle_floating_terminal, { desc = "Toggle Floating Terminal", silent = true })
map("n", "<leader>tt", toggle_floating_terminal, { desc = "Toggle Floating Terminal", silent = true })
