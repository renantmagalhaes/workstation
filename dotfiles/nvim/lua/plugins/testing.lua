-- Test Explorer (VS Code "Testing" panel): run / debug tests from the editor, pass/fail in the gutter.
-- Adapters: pytest, go test, jest, vitest. "Debug test" uses the debuggers from lua/plugins/debug.lua.

-- nt("run.run", arg) -> function calling require("neotest").run.run(arg). `arg` may be a function,
-- evaluated at key-press time (e.g. the current file name).
local function nt(path, arg)
  return function()
    local fn = require("neotest")
    for part in path:gmatch("[^.]+") do
      fn = fn[part]
    end
    if type(arg) == "function" then
      fn(arg())
    else
      fn(arg)
    end
  end
end

local function current_file()
  return vim.fn.expand("%")
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "fredrikaverpil/neotest-golang",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    cmd = "Neotest",
    keys = {
      { "<leader>tr", nt("run.run"), desc = "Run nearest test" },
      { "<leader>tf", nt("run.run", current_file), desc = "Run tests in file" },
      { "<leader>ta", nt("run.run", vim.uv.cwd), desc = "Run all tests" },
      { "<leader>tl", nt("run.run_last"), desc = "Re-run last test" },
      { "<leader>td", nt("run.run", { strategy = "dap" }), desc = "Debug nearest test" },
      { "<leader>tS", nt("run.stop"), desc = "Stop tests" },
      { "<leader>ts", nt("summary.toggle"), desc = "Toggle test explorer" },
      { "<leader>to", nt("output.open", { enter = true, auto_close = true }), desc = "Show test output" },
      { "<leader>tO", nt("output_panel.toggle"), desc = "Toggle test output panel" },
      { "<leader>tw", nt("watch.toggle", current_file), desc = "Watch tests in file" },
      -- (]t / [t are TODO comments)
      { "]T", nt("jump.next", { status = "failed" }), desc = "Next failed test" },
      { "[T", nt("jump.prev", { status = "failed" }), desc = "Previous failed test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({ dap = { justMyCode = false } }),
          require("neotest-golang")({}),
          require("neotest-jest")({}),
          require("neotest-vitest")({}),
        },
        -- Left sidebar like VS Code's Testing view (the right edge belongs to the minimap)
        summary = { open = "topleft vsplit | vertical resize 45" },
        status = { virtual_text = true },
        output = { open_on_run = false },
        quickfix = { open = false },
      })
    end,
  },
}
