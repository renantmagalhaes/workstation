-- Modern, Detailed & Minimalist Startup Dashboard (Alpha)
return {
  {
    "goolord/alpha-nvim",
    lazy = false,
    cmd = { "Alpha", "Dashboard" },
    keys = {
      { "<leader>;", "<cmd>Dashboard<CR>", desc = "Toggle Dashboard" },
      { "<leader>a", "<cmd>Dashboard<CR>", desc = "Toggle Dashboard" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Sleek, razor-sharp ASCII Logo (Cyberdream aesthetic)
      local header = {
        type = "text",
        val = {
          [[        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
          [[        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
          [[        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
          [[        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
          [[        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
          [[        ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
        opts = {
          position = "center",
          hl = "Function",
        },
      }

      -- Dynamic Info Pill (Project / Git Branch / Plugin Count / Neovim Version)
      local info_badge = {
        type = "text",
        val = function()
          local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("%s+", "")
          local branch_text = (branch ~= "") and ("  •   " .. branch) or ""
          local stats = require("lazy").stats()
          local v = vim.version()
          local nvim_ver = string.format("v%d.%d.%d", v.major, v.minor, v.patch)
          return string.format(" %s%s  •  󰏖 %d plugins  •   %s", cwd, branch_text, stats.count, nvim_ver)
        end,
        opts = {
          position = "center",
          hl = "SpecialComment",
        },
      }

      -- Dynamic Recent Files: prioritizes files from current workspace structure, falls back to global files
      local function mru_val()
        local oldfiles = vim.v.oldfiles or {}
        local cwd = vim.fs.normalize(vim.fn.getcwd())
        local devicons_ok, devicons = pcall(require, "nvim-web-devicons")

        local workspace_files = {}
        local global_files = {}

        for _, file in ipairs(oldfiles) do
          if vim.fn.filereadable(file) == 1
            and not file:find("commit_editmsg")
            and not file:find("/tmp/")
            and not file:find("%.git/")
          then
            local norm_file = vim.fs.normalize(file)
            -- Check if file belongs to the current workspace folder structure
            if norm_file:sub(1, #cwd) == cwd and norm_file ~= cwd then
              table.insert(workspace_files, file)
            else
              table.insert(global_files, file)
            end
          end
        end

        local is_workspace = #workspace_files > 0
        local target_files = is_workspace and workspace_files or global_files
        local section_title = is_workspace and "  Recent Files (Workspace)" or "  Recent Files (Global)"

        local buttons = {}
        for _, file in ipairs(target_files) do
          if #buttons >= 5 then break end

          local display = file
          if file:sub(1, #cwd) == cwd then
            display = file:sub(#cwd + 2)
          else
            display = vim.fn.fnamemodify(file, ":~")
          end

          if #display > 34 then
            display = "..." .. display:sub(#display - 30)
          end

          local icon = ""
          if devicons_ok then
            local ext = vim.fn.fnamemodify(file, ":e")
            local i = devicons.get_icon(file, ext, { default = true })
            if i then icon = i end
          end

          local idx = tostring(#buttons + 1)
          local btn_text = string.format("%s  %s", icon, display)
          local escaped_path = vim.fn.fnameescape(file)
          local btn = dashboard.button(idx, btn_text, string.format("<cmd>edit %s<CR>", escaped_path))
          btn.opts.hl_shortcut = "Number"
          btn.opts.width = 48
          btn.opts.align_shortcut = "right"
          btn.opts.shortcut = "[" .. idx .. "]"
          table.insert(buttons, btn)
        end

        if #buttons == 0 then
          return {}
        end

        local items = {
          {
            type = "text",
            val = section_title,
            opts = { hl = "SpecialComment", position = "center" },
          },
          { type = "padding", val = 1 },
        }
        for _, b in ipairs(buttons) do
          table.insert(items, b)
        end
        table.insert(items, { type = "padding", val = 1 })
        return items
      end

      local mru_section = {
        type = "group",
        val = mru_val,
        opts = { shrink_margin = false },
      }

      -- Helper for styled action buttons
      local function action_btn(sc, txt, cmd, shortcut_label)
        local b = dashboard.button(sc, txt, cmd)
        b.opts.hl_shortcut = "Keyword"
        b.opts.width = 48
        b.opts.align_shortcut = "right"
        if shortcut_label then
          b.opts.shortcut = shortcut_label
        end
        return b
      end

      local actions_header = {
        type = "text",
        val = "⚡ Quick Actions",
        opts = { hl = "SpecialComment", position = "center" },
      }

      local action_buttons = {
        action_btn("f", "  Find File", "<cmd>Telescope find_files hidden=true<CR>", "SPC SPC"),
        action_btn("g", "  Find Text (Grep)", "<cmd>Telescope live_grep<CR>", "SPC fg"),
        action_btn("s", "  Restore Session", "<cmd>lua require('persistence').load()<CR>", "s"),
        action_btn("r", "  Recent Files (All)", "<cmd>Telescope oldfiles<CR>", "SPC fr"),
        action_btn("t", "  Floating Terminal", "<cmd>lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<leader>tt', true, false, true), 'm', true)<CR>", "Ctrl+/"),
        action_btn("c", "  Command Palette", "<cmd>Telescope commands<CR>", "SPC :"),
        action_btn("e", "  File Explorer", "<cmd>NvimTreeToggle<CR>", "SPC e"),
        action_btn("n", "  New File", "<cmd>ene <BAR> startinsert<CR>", "n"),
        action_btn("q", "  Quit Neovim", "<cmd>confirm qa<CR>", "Ctrl+d"),
      }

      -- Footer with live statistics and datetime
      local footer = {
        type = "text",
        val = function()
          local stats = require("lazy").stats()
          local datetime = os.date(" %Y-%m-%d   %H:%M")
          local load_time = (stats.startuptime > 0)
            and string.format("󱐋 Loaded %d plugins in %.1fms", stats.count, stats.startuptime)
            or string.format("󰏖 %d plugins loaded", stats.count)
          return {
            datetime .. "   " .. load_time,
            "",
            "⚡ Ready to build",
          }
        end,
        opts = {
          position = "center",
          hl = "Comment",
        },
      }

      -- Layout composition
      dashboard.config.layout = {
        { type = "padding", val = 2 },
        header,
        { type = "padding", val = 1 },
        info_badge,
        { type = "padding", val = 2 },
        mru_section,
        actions_header,
        { type = "padding", val = 1 },
        { type = "group", val = action_buttons, opts = { shrink_margin = false } },
        { type = "padding", val = 2 },
        footer,
      }

      alpha.setup(dashboard.config)

      -- Automatically open dashboard by default when launching without concrete file arguments (e.g. `nvim` or `nvim .`)
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("AlphaAutoStart", { clear = true }),
        nested = true,
        callback = function()
          local should_open_dashboard = false
          local argc = vim.fn.argc()
          if argc == 0 then
            should_open_dashboard = true
          elseif argc == 1 then
            local arg = vim.fn.argv(0)
            if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
              should_open_dashboard = true
            end
          end

          if should_open_dashboard and not vim.g.started_by_firenvim then
            alpha.start(false, dashboard.config)
          end
        end,
      })

      -- Smart toggle function: opens dashboard if on a file, returns to file if on dashboard
      local function toggle_dashboard()
        if vim.bo.filetype == "alpha" then
          local alt = vim.fn.bufnr("#")
          if alt > 0 and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
            vim.cmd("buffer #")
            return
          end
          local bufs = vim.tbl_filter(function(b)
            return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and vim.bo[b].filetype ~= "alpha" and vim.bo[b].buftype == ""
          end, vim.api.nvim_list_bufs())
          if #bufs > 0 then
            vim.api.nvim_set_current_buf(bufs[1])
            return
          end
        else
          alpha.start(false, dashboard.config)
        end
      end

      -- User command :Dashboard (toggles back and forth)
      pcall(vim.api.nvim_create_user_command, "Dashboard", toggle_dashboard, { desc = "Toggle Dashboard" })

      -- Disable folding and line numbers on dashboard, and let <Esc> return to previous buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function(event)
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.cursorline = false

          -- Press Esc to quickly return to previous open file buffer
          vim.keymap.set("n", "<Esc>", function()
            local alt = vim.fn.bufnr("#")
            if alt > 0 and vim.api.nvim_buf_is_valid(alt) and vim.bo[alt].buflisted then
              vim.cmd("buffer #")
            end
          end, { buffer = event.buf, silent = true, desc = "Return to previous file" })
        end,
      })
    end,
  },
}
