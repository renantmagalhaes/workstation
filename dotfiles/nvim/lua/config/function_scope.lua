-- Keeps the enclosing function's indent guide coloured while the cursor is deeper inside it.
-- snacks.indent colours the innermost block (from indentation); this adds the function/method
-- around the cursor (from tree-sitter), so with the cursor in an `if` inside a `for` inside a
-- `def`, both the `if` body and the `def` body keep their coloured line.
-- Files without a tree-sitter parser simply show the block line only.
local M = {}

local ns = vim.api.nvim_create_namespace("function_scope_line")
local current -- { win, buf, from, to, col, hl, leftcol } (rows are 1-indexed)

-- Tree-sitter node types differ per language; match them by name instead of keeping lists:
-- function_definition, function_declaration, method_definition, arrow_function, func_literal, ...
local function is_function(t)
  if t:find("call") or t:find("argument") or t:find("parameter") or t:find("signature") then
    return false
  end
  if t:find("type") or t:find("name") or t:find("body") or t:find("index") then
    return false
  end
  return t:find("function") ~= nil or t:find("method") ~= nil or t == "func_literal" or t == "closure_expression"
end

-- Display width of the leading whitespace (tabs expanded)
local function indent_width(line, ts)
  local ws = line:match("^[ \t]*")
  local w = 0
  for i = 1, #ws do
    w = ws:byte(i) == 9 and (w + ts - (w % ts)) or (w + 1)
  end
  return w, #ws == #line
end

local function enabled(buf)
  return Snacks
    and Snacks.indent.enabled
    and vim.bo[buf].buftype == ""
    and vim.g.snacks_indent ~= false
    and vim.b[buf].snacks_indent ~= false
end

-- Function scope around the cursor of the current window, or nil
local function find()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  if not enabled(buf) then
    return nil
  end
  -- Use the first non-blank of the nearest non-blank line, so blank lines and col 0 still count
  local lnum = vim.fn.prevnonblank(vim.fn.line("."))
  if lnum == 0 then
    return nil
  end
  local first_col = #vim.fn.getline(lnum):match("^%s*")
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf, pos = { lnum - 1, first_col } })
  if not ok then
    return nil
  end
  while node do
    if is_function(node:type()) then
      local sr, _, er, ec = node:range()
      if ec == 0 then
        er = er - 1 -- node ends at the start of the next line
      end
      if er > sr then
        local ts = vim.bo[buf].tabstop
        local col = indent_width(vim.fn.getline(sr + 1), ts)
        local hls = Snacks.config.indent.scope.hl
        local level = math.floor(col / vim.fn.shiftwidth()) + 1
        return {
          win = win,
          buf = buf,
          from = sr + 2, -- body starts below the header line
          to = er + 1,
          col = col,
          hl = type(hls) == "table" and hls[(level - 1) % #hls + 1] or hls,
          leftcol = vim.fn.winsaveview().leftcol,
        }
      end
    end
    node = node:parent()
  end
  return nil
end

local function same(a, b)
  if a == nil or b == nil then
    return a == b
  end
  for _, k in ipairs({ "win", "buf", "from", "to", "col", "hl", "leftcol" }) do
    if a[k] ~= b[k] then
      return false
    end
  end
  return true
end

local function redraw(s)
  if s and vim.api.nvim_win_is_valid(s.win) then
    Snacks.util.redraw_range(s.win, s.from, s.to)
  end
end

local function update()
  local ok, new = pcall(find)
  new = ok and new or nil
  if same(current, new) then
    return
  end
  local prev = current
  current = new
  redraw(prev)
  redraw(current)
end

function M.setup()
  vim.api.nvim_set_decoration_provider(ns, {
    on_win = function(_, win, buf, top, bottom)
      local s = current
      if not s or s.win ~= win or s.buf ~= buf or not enabled(buf) then
        return false
      end
      local col = s.col - s.leftcol
      if col < 0 then
        return false
      end
      local from, to = math.max(s.from, top + 1), math.min(s.to, bottom + 1)
      if from > to then
        return false
      end
      local ts = vim.bo[buf].tabstop
      for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, from - 1, to, false)) do
        local w, blank = indent_width(line, ts)
        if blank or w > s.col then
          vim.api.nvim_buf_set_extmark(buf, ns, from + i - 2, 0, {
            virt_text = { { Snacks.config.indent.scope.char or "│", s.hl } },
            virt_text_pos = "overlay",
            virt_text_win_col = col,
            hl_mode = "combine",
            priority = 199, -- just under the snacks block line, which is the same colour anyway
            ephemeral = true,
          })
        end
      end
      return false
    end,
  })

  vim.api.nvim_create_autocmd(
    { "CursorMoved", "CursorMovedI", "BufEnter", "WinEnter", "TextChanged", "TextChangedI", "WinScrolled" },
    { group = vim.api.nvim_create_augroup("FunctionScopeLine", { clear = true }), callback = update }
  )
end

return M
