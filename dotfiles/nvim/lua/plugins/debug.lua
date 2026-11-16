-- Debugging (VS Code "Run and Debug"): nvim-dap + dap-ui + inline variable values.
-- Adapters (debugpy, delve, js-debug-adapter) are installed through Mason on first use.
-- `.vscode/launch.json` in the project is picked up automatically by nvim-dap.

local mason_root = vim.fn.stdpath("data") .. "/mason"

-- Install the Mason packages that are missing (in the background)
local function ensure_mason_packages(names)
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return
  end
  for _, name in ipairs(names) do
    if registry.has_package(name) then
      local pkg = registry.get_package(name)
      if not pkg:is_installed() and not pkg:is_installing() then
        vim.notify("Installing debug adapter " .. name .. "...", vim.log.levels.INFO)
        pkg:install({}, function(success)
          vim.schedule(function()
            if success then
              vim.notify("✓ " .. name .. " installed", vim.log.levels.INFO)
            else
              vim.notify("Failed to install " .. name .. " (see :Mason)", vim.log.levels.ERROR)
            end
          end)
        end)
      end
    end
  end
end

local function dap_call(fn, ...)
  local args = { ... }
  return function()
    require("dap")[fn](unpack(args))
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
      "williamboman/mason.nvim",
    },
    cmd = { "DapContinue", "DapToggleBreakpoint", "DapNew" },
    -- VS Code keys. Terminals often send Shift+F5 as <F17>, Ctrl+Shift+F5 as <F29>, Shift+F11 as <F23>.
    -- Note: Windows Terminal uses F11 for fullscreen by default; use <leader>Di there (or unbind it).
    keys = {
      { "<F5>", dap_call("continue"), desc = "Debug: Start / Continue (F5)" },
      { "<S-F5>", dap_call("terminate"), desc = "Debug: Stop (Shift+F5)" },
      { "<F17>", dap_call("terminate"), desc = "Debug: Stop (Shift+F5)" },
      { "<C-S-F5>", dap_call("restart"), desc = "Debug: Restart (Ctrl+Shift+F5)" },
      { "<F29>", dap_call("restart"), desc = "Debug: Restart (Ctrl+Shift+F5)" },
      { "<F9>", dap_call("toggle_breakpoint"), desc = "Debug: Toggle Breakpoint (F9)" },
      { "<F10>", dap_call("step_over"), desc = "Debug: Step Over (F10)" },
      { "<F11>", dap_call("step_into"), desc = "Debug: Step Into (F11)" },
      { "<S-F11>", dap_call("step_out"), desc = "Debug: Step Out (Shift+F11)" },
      { "<F23>", dap_call("step_out"), desc = "Debug: Step Out (Shift+F11)" },

      { "<leader>Dc", dap_call("continue"), desc = "Start / Continue" },
      { "<leader>Db", dap_call("toggle_breakpoint"), desc = "Toggle Breakpoint" },
      {
        "<leader>DB",
        function()
          vim.ui.input({ prompt = "Breakpoint condition" }, function(cond)
            if cond and cond ~= "" then
              require("dap").set_breakpoint(cond)
            end
          end)
        end,
        desc = "Conditional Breakpoint",
      },
      {
        "<leader>Dl",
        function()
          vim.ui.input({ prompt = "Log message ({expr} is interpolated)" }, function(msg)
            if msg and msg ~= "" then
              require("dap").set_breakpoint(nil, nil, msg)
            end
          end)
        end,
        desc = "Logpoint",
      },
      { "<leader>DX", dap_call("clear_breakpoints"), desc = "Clear All Breakpoints" },
      { "<leader>Do", dap_call("step_over"), desc = "Step Over" },
      { "<leader>Di", dap_call("step_into"), desc = "Step Into" },
      { "<leader>DO", dap_call("step_out"), desc = "Step Out" },
      { "<leader>DC", dap_call("run_to_cursor"), desc = "Run to Cursor" },
      { "<leader>Dr", dap_call("restart"), desc = "Restart" },
      { "<leader>Dt", dap_call("terminate"), desc = "Stop" },
      { "<leader>Dp", dap_call("pause"), desc = "Pause" },
      {
        "<leader>DR",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL / Debug Console",
      },
      {
        "<leader>Du",
        function()
          require("dapui").toggle({ reset = true })
        end,
        desc = "Toggle Debug UI",
      },
      {
        "<leader>De",
        function()
          require("dapui").eval(nil, { enter = true })
        end,
        mode = { "n", "x" },
        desc = "Evaluate Expression",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Gutter icons (VS Code style)
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#ffcc00" })
      vim.api.nvim_set_hl(0, "DapStoppedLine", { link = "Visual" })
      local sign = vim.fn.sign_define
      sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
      sign("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint" })
      sign("DapBreakpointRejected", { text = "○", texthl = "DapBreakpoint" })
      sign("DapLogPoint", { text = "◉", texthl = "DapLogPoint" })
      sign("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine" })

      dapui.setup()
      require("nvim-dap-virtual-text").setup({ commented = true })

      -- Open the debug panels when a session starts, close them when it ends
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      local function setup_adapters()
        -- Python: debugpy from Mason runs the adapter; the debuggee uses the project's
        -- interpreter ($VIRTUAL_ENV, ./venv, ./.venv), like VS Code's interpreter picker.
        require("dap-python").setup(mason_root .. "/packages/debugpy/venv/bin/python")

        -- Go: delve from Mason
        require("dap-go").setup({ delve = { path = mason_root .. "/bin/dlv" } })

        -- JavaScript / TypeScript (Node): vscode-js-debug, the same debugger VS Code uses
        for _, adapter in ipairs({ "pwa-node", "node" }) do
          dap.adapters[adapter] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = { command = mason_root .. "/bin/js-debug-adapter", args = { "${port}" } },
          }
        end
        for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
          dap.configurations[ft] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch current file (Node)",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach to Node process",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }
        end
      end

      setup_adapters()
      ensure_mason_packages({ "debugpy", "delve", "js-debug-adapter" })
    end,
  },
}
