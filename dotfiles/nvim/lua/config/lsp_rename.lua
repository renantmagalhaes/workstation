-- LSP-aware file renames: like VS Code, renaming or moving a file updates the imports that point
-- at it (workspace/willRenameFiles), saves the files that were changed and tells the servers.
-- Used by the file tree (F2 / r / cut + paste) and by <leader>cR for the current buffer.
local M = {}

local function params(from, to)
  return { files = { { oldUri = vim.uri_from_fname(from), newUri = vim.uri_from_fname(to) } } }
end

-- Once the file is already moved (file tree), edits addressed to its old path must go to the new one
local function remap_uris(edit, from, to)
  local old_prefix, new_prefix = vim.uri_from_fname(from), vim.uri_from_fname(to)
  local function remap(uri)
    if uri == old_prefix or vim.startswith(uri, old_prefix .. "/") then
      return new_prefix .. uri:sub(#old_prefix + 1)
    end
    return uri
  end
  if edit.changes then
    local changes = {}
    for uri, edits in pairs(edit.changes) do
      changes[remap(uri)] = edits
    end
    edit.changes = changes
  end
  for _, change in ipairs(edit.documentChanges or {}) do
    if change.textDocument then
      change.textDocument.uri = remap(change.textDocument.uri)
    end
  end
  return edit
end

-- Buffers touched by a workspace edit
local function edited_buffers(edit)
  local uris = {}
  for uri in pairs(edit.changes or {}) do
    uris[#uris + 1] = uri
  end
  for _, change in ipairs(edit.documentChanges or {}) do
    if change.textDocument then
      uris[#uris + 1] = change.textDocument.uri
    end
  end
  local bufs = {}
  for _, uri in ipairs(uris) do
    bufs[vim.uri_to_bufnr(uri)] = true
  end
  return bufs
end

-- Ask every server which edits the rename needs. Must run while the file is still at `from`:
-- servers (e.g. ts_ls) only return the edits for the moved file's own relative imports then.
local function request_edits(from, to)
  local result = {}
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client:supports_method("workspace/willRenameFiles") then
      local resp = client:request_sync("workspace/willRenameFiles", params(from, to), 3000, 0)
      if resp and resp.result then
        result[#result + 1] = { edit = resp.result, encoding = client.offset_encoding }
      end
    end
  end
  return result
end

-- Apply the edits and save the files they changed.
-- `moved` = the file is already at `to`, so edits addressed to its old path go to the new one.
local function apply_edits(edits, from, to, moved)
  local updated = 0
  for _, item in ipairs(edits) do
    local edit = moved and remap_uris(item.edit, from, to) or item.edit
    -- Remember which buffers were open / unsaved before, to save and close only what we touched
    local before = {}
    for buf in pairs(edited_buffers(edit)) do
      before[buf] = {
        loaded = vim.api.nvim_buf_is_loaded(buf),
        listed = vim.bo[buf].buflisted,
        modified = vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified,
      }
    end
    vim.lsp.util.apply_workspace_edit(edit, item.encoding)
    for buf, was in pairs(before) do
      if vim.api.nvim_buf_is_loaded(buf) then
        updated = updated + 1
        -- Save like VS Code does after a refactoring (files.refactoring.autoSave), without
        -- running format-on-save over code the user didn't touch
        if not was.modified and vim.bo[buf].modified then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("silent noautocmd write")
          end)
        end
        -- Files opened only to apply the edit don't become tabs
        if not was.loaded and not vim.bo[buf].modified then
          pcall(vim.api.nvim_buf_delete, buf, {})
        elseif not was.listed then
          vim.bo[buf].buflisted = false
        end
      end
    end
  end
  return updated
end

-- Edits requested by before_rename(), applied once the tree reports the rename succeeded
local pending = {}

local function did_rename(from, to)
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client:supports_method("workspace/didRenameFiles") then
      client:notify("workspace/didRenameFiles", params(from, to))
    end
  end
end

local function report(updated, to)
  if updated > 0 then
    local name = vim.fn.fnamemodify(to, ":t")
    vim.notify(("Renamed %s, updated references in %d file(s)"):format(name, updated), vim.log.levels.INFO)
  end
end

local function warn_failed(err)
  vim.notify("Updating references failed: " .. tostring(err), vim.log.levels.WARN)
end

-- Called by nvim-tree right before it renames / moves a file or folder: only ask for the edits,
-- nothing changes until the move succeeded
function M.before_rename(from, to)
  local ok, edits = pcall(request_edits, from, to)
  if not ok then
    return warn_failed(edits)
  end
  pending[from .. "\0" .. to] = edits
  vim.schedule(function() -- the move is synchronous; drop leftovers of a failed one
    pending[from .. "\0" .. to] = nil
  end)
end

-- Called by nvim-tree after it renamed / moved a file or folder
function M.on_rename(from, to)
  local key = from .. "\0" .. to
  local edits = pending[key]
  pending[key] = nil
  local ok, updated = pcall(apply_edits, edits or {}, from, to, true)
  if not ok then
    warn_failed(updated)
    updated = 0
  end
  did_rename(from, to)
  report(updated, to)
end

-- Rename the current buffer's file (prompt), updating references first
function M.rename_file()
  local buf = vim.api.nvim_get_current_buf()
  local from = vim.api.nvim_buf_get_name(buf)
  if vim.bo[buf].buftype ~= "" or from == "" or not vim.uv.fs_stat(from) then
    vim.notify("This buffer is not a file on disk", vim.log.levels.WARN)
    return
  end
  if vim.bo[buf].modified then
    vim.notify("Save the file before renaming it", vim.log.levels.WARN)
    return
  end
  local default = vim.fn.fnamemodify(from, ":.")
  vim.ui.input({ prompt = "Rename file", default = default, completion = "file" }, function(input)
    if not input or input == "" or input == default then
      return
    end
    local to = vim.fs.normalize(vim.fn.fnamemodify(input, ":p"))
    if vim.uv.fs_stat(to) then
      vim.notify(to .. " already exists", vim.log.levels.ERROR)
      return
    end
    local ok, updated = pcall(function()
      return apply_edits(request_edits(from, to), from, to, false)
    end)
    if not ok then
      warn_failed(updated)
      updated = 0
    end
    vim.fn.mkdir(vim.fs.dirname(to), "p")
    if vim.fn.rename(from, to) ~= 0 then
      vim.notify("Failed to rename " .. from, vim.log.levels.ERROR)
      return
    end
    -- Show the new file wherever the old one was open
    local new = vim.fn.bufadd(to)
    vim.bo[new].buflisted = true
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.api.nvim_win_call(win, function()
        vim.cmd("buffer " .. new)
      end)
    end
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    did_rename(from, to)
    report(updated, to)
  end)
end

return M
