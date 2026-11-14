-- Utility for opening and copying Git Web URLs (GitHub, GitLab, Bitbucket)
local M = {}

function M.get_url(opts)
  opts = opts or {}
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file in active buffer", vim.log.levels.WARN, { title = "Git Web" })
    return nil
  end

  local file_dir = vim.fn.expand("%:p:h")
  local git_dir = vim.fn.systemlist("git -C " .. vim.fn.shellescape(file_dir) .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 or not git_dir or git_dir == "" then
    vim.notify("Current file is not inside a git repository", vim.log.levels.WARN, { title = "Git Web" })
    return nil
  end

  local rel_path = file:sub(#git_dir + 2)

  local start_line, end_line
  if opts.range and opts.line1 and opts.line2 and opts.line1 ~= opts.line2 then
    start_line, end_line = opts.line1, opts.line2
  elseif opts.visual then
    local vstart = vim.fn.getpos("'<")[2]
    local vend = vim.fn.getpos("'>")[2]
    if vstart > vend then
      vstart, vend = vend, vstart
    end
    start_line, end_line = vstart, vend
  else
    local cur = vim.fn.line(".")
    start_line, end_line = cur, cur
  end

  local line_arg = start_line == end_line and tostring(start_line) or (start_line .. "-" .. end_line)

  -- 1. Try GitHub CLI (gh) first if available
  local gh_bin = vim.fn.exepath("gh")
  if gh_bin == "" and vim.fn.executable("/home/linuxbrew/.linuxbrew/bin/gh") == 1 then
    gh_bin = "/home/linuxbrew/.linuxbrew/bin/gh"
  end

  if gh_bin ~= "" then
    local cmd = string.format(
      "cd %s && %s browse -n %s:%s 2>/dev/null",
      vim.fn.shellescape(git_dir),
      vim.fn.shellescape(gh_bin),
      vim.fn.shellescape(rel_path),
      line_arg
    )
    local out = vim.fn.systemlist(cmd)[1]
    if vim.v.shell_error == 0 and out and out:match("^https?://") then
      return out
    end
  end

  -- 2. Fallback: Parse remote origin directly
  local remote_url = vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_dir) .. " remote get-url origin")[1]
  if not remote_url or remote_url == "" then
    vim.notify("No git remote 'origin' found", vim.log.levels.WARN, { title = "Git Web" })
    return nil
  end

  local branch = vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_dir) .. " rev-parse --abbrev-ref HEAD")[1] or "main"
  if branch == "HEAD" then
    branch = vim.fn.systemlist("git -C " .. vim.fn.shellescape(git_dir) .. " rev-parse --short HEAD")[1] or "main"
  end

  local host, path
  if remote_url:match("^git@([^:]+):(.+)$") then
    host, path = remote_url:match("^git@([^:]+):(.+)$")
  elseif remote_url:match("^https?://([^/]+)/(.+)$") then
    host, path = remote_url:match("^https?://([^/]+)/(.+)$")
  end

  if not host or not path then
    vim.notify("Could not parse remote URL: " .. remote_url, vim.log.levels.ERROR, { title = "Git Web" })
    return nil
  end

  path = path:gsub("%.git$", "")

  if host:find("gitlab") then
    local frag = start_line == end_line and ("#L" .. start_line) or string.format("#L%d-%d", start_line, end_line)
    return string.format("https://%s/%s/-/blob/%s/%s%s", host, path, branch, rel_path, frag)
  elseif host:find("bitbucket") then
    local frag = start_line == end_line and ("#lines-" .. start_line) or string.format("#lines-%d:%d", start_line, end_line)
    return string.format("https://%s/%s/src/%s/%s%s", host, path, branch, rel_path, frag)
  else
    local frag = start_line == end_line and ("#L" .. start_line) or string.format("#L%d-L%d", start_line, end_line)
    return string.format("https://%s/%s/blob/%s/%s%s", host, path, branch, rel_path, frag)
  end
end

function M.open(opts)
  local url = M.get_url(opts)
  if url then
    vim.ui.open(url)
    vim.notify(url, vim.log.levels.INFO, { title = "Opened in Browser", icon = " " })
  end
end

function M.copy(opts)
  local url = M.get_url(opts)
  if url then
    vim.fn.setreg("+", url)
    vim.fn.setreg('"', url)
    vim.notify(url, vim.log.levels.INFO, { title = "Copied to Clipboard", icon = "📋" })
  end
end

return M
