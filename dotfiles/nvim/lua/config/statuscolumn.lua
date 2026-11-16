-- VS Code-style gutter: [signs][line number][fold marker]
-- The built-in fold column prints nesting digits (2, 3, ...) when it is narrower than the fold
-- depth; this shows only ▾ (open) / ▸ (closed) on the line where a fold starts. Click it to toggle.
local M = {}

local function fold_starts_here(lnum)
  local expr = vim.wo.foldmethod == "expr" and vim.wo.foldexpr or ""
  if expr:find("treesitter.foldexpr", 1, true) then
    local ok, level = pcall(vim.treesitter.foldexpr, lnum)
    return ok and type(level) == "string" and level:sub(1, 1) == ">"
  end
  return vim.fn.foldlevel(lnum) > vim.fn.foldlevel(lnum - 1)
end

function M.fold()
  local lnum = vim.v.lnum
  if vim.v.virtnum ~= 0 or vim.bo.buftype ~= "" or vim.wo.foldmethod == "manual" then
    return " "
  end
  if vim.fn.foldclosed(lnum) == lnum then
    return "▸"
  end
  return fold_starts_here(lnum) and "▾" or " "
end

-- Toggle the fold on `line` of window `winid` (there is no :foldtoggle; use :foldopen / :foldclose)
function M.toggle(winid, line)
  vim.api.nvim_win_call(winid, function()
    if vim.fn.foldlevel(line) == 0 then
      return
    end
    if vim.fn.foldclosed(line) ~= -1 then
      vim.cmd(line .. "foldopen")
    else
      vim.cmd(line .. "foldclose")
    end
  end)
end

-- Mouse click on the marker: toggle the fold on that line
function M.click()
  local pos = vim.fn.getmousepos()
  if pos.winid == 0 or pos.line == 0 then
    return
  end
  M.toggle(pos.winid, pos.line)
end

_G.StatusColumnFoldClick = M.click

local FILE_COLUMN = "%s%l %#FoldColumn#%@v:lua.StatusColumnFoldClick@%{v:lua.require'config.statuscolumn'.fold()}%T%* "

-- File buffers get the full gutter; special windows (file tree, panels) keep just their signs
function M.render()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= "" or not (vim.wo[win].number or vim.wo[win].relativenumber) then
    return "%s"
  end
  return FILE_COLUMN
end

M.expr = "%!v:lua.require'config.statuscolumn'.render()"

return M
