local M = {}

-- Returns a list of files prioritizing recently opened/active files in the workspace (cwd),
-- followed by the rest of the project files.
local function get_project_files(cwd, hidden)
  local cmd
  if vim.fn.executable("rg") == 1 then
    cmd = { "rg", "--files" }
    if hidden ~= false then
      table.insert(cmd, "--hidden")
      table.insert(cmd, "-g")
      table.insert(cmd, "!.git")
    end
  elseif vim.fn.executable("fd") == 1 then
    cmd = { "fd", "--type", "f" }
    if hidden ~= false then
      table.insert(cmd, "--hidden")
      table.insert(cmd, "--exclude")
      table.insert(cmd, ".git")
    end
  else
    cmd = { "find", ".", "-type", "f" }
    if hidden ~= false then
      table.insert(cmd, "-not")
      table.insert(cmd, "-path")
      table.insert(cmd, "*/.git/*")
    else
      table.insert(cmd, "-not")
      table.insert(cmd, "-path")
      table.insert(cmd, "*/.*")
    end
  end

  local res = vim.system(cmd, { cwd = cwd, text = true }):wait()
  if res and res.code == 0 and res.stdout then
    local list = {}
    for line in res.stdout:gmatch("[^\r\n]+") do
      local clean = line:gsub("^%./", "")
      table.insert(list, clean)
    end
    return list
  end
  return {}
end

--- Custom Telescope picker that lists the most recent files of the current directory first,
--- while keeping all project files searchable (VS Code Quick Open behavior).
---@param opts table|nil
function M.find_files_mru(opts)
  opts = opts or {}
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local make_entry = require("telescope.make_entry")

  local cwd = vim.fs.normalize(opts.cwd or vim.fn.getcwd())
  local seen = {}
  local results = {}

  local current_buf = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(current_buf)
  local norm_current_file = current_file ~= "" and vim.fs.normalize(current_file) or nil

  local function add_file(norm_path, rel_path)
    if not seen[norm_path] then
      seen[norm_path] = true
      table.insert(results, rel_path)
    end
  end

  local function is_valid(path)
    local stat = vim.uv.fs_stat(path)
    if not stat or stat.type ~= "file" then
      return false
    end
    if path:find("/%.git/") or path:find("COMMIT_EDITMSG") or path:find("git%-rebase%-todo") then
      return false
    end
    return true
  end

  -- 1. Alternate buffer (#): The file the user was in right before current
  local alt_buf = vim.fn.bufnr("#")
  if alt_buf > 0 and alt_buf ~= current_buf and vim.api.nvim_buf_is_loaded(alt_buf) then
    local alt_name = vim.api.nvim_buf_get_name(alt_buf)
    if alt_name ~= "" then
      local norm = vim.fs.normalize(alt_name)
      if vim.startswith(norm, cwd) and is_valid(norm) then
        local rel = norm:sub(#cwd + 2)
        if rel ~= "" then
          add_file(norm, rel)
        end
      end
    end
  end

  -- 2. Other loaded buffers in cwd (newest first)
  local bufs = vim.api.nvim_list_bufs()
  table.sort(bufs, function(a, b) return a > b end)
  for _, buf in ipairs(bufs) do
    if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then
        local norm = vim.fs.normalize(name)
        if vim.startswith(norm, cwd) and is_valid(norm) then
          local rel = norm:sub(#cwd + 2)
          if rel ~= "" then
            add_file(norm, rel)
          end
        end
      end
    end
  end

  -- 3. Oldfiles in cwd (persisted MRU from vim.v.oldfiles)
  for _, file in ipairs(vim.v.oldfiles or {}) do
    local norm = vim.fs.normalize(file)
    if norm ~= norm_current_file and vim.startswith(norm, cwd) and is_valid(norm) then
      local rel = norm:sub(#cwd + 2)
      if rel ~= "" then
        add_file(norm, rel)
      end
    end
  end

  -- 4. Current buffer file (placed at end of recent files so it's searchable but not first)
  if norm_current_file and vim.startswith(norm_current_file, cwd) and is_valid(norm_current_file) then
    local rel = norm_current_file:sub(#cwd + 2)
    if rel ~= "" then
      add_file(norm_current_file, rel)
    end
  end

  -- 5. All other project files in cwd
  local project_files = get_project_files(cwd, opts.hidden)
  for _, rel in ipairs(project_files) do
    local norm = vim.fs.normalize(cwd .. "/" .. rel)
    add_file(norm, rel)
  end

  opts.cwd = cwd
  pickers
    .new(opts, {
      prompt_title = opts.prompt_title or "Find Files (Recent First)",
      finder = finders.new_table({
        results = results,
        entry_maker = make_entry.gen_from_file(opts),
      }),
      previewer = conf.file_previewer(opts),
      sorter = conf.file_sorter(opts),
    })
    :find()
end

vim.api.nvim_create_user_command("FindFilesMRU", function()
  M.find_files_mru()
end, { desc = "Find files with workspace MRU priority" })

return M
