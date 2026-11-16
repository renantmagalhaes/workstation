-- Language Server Protocol (LSP) with On-Demand Per-File Auto-Installation
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Setup Mason
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })

      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp.default_capabilities()
      local is_nvim_011 = vim.fn.has("nvim-0.11") == 1

      -- Global LspAttach autocmd for keymaps & breadcrumbs
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(event)
          local bufnr = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentSymbolProvider then
            local ok_navic, navic = pcall(require, "nvim-navic")
            if ok_navic then
              pcall(navic.attach, client, bufnr)
            end
          end

          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
          map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
          map("n", "gr", vim.lsp.buf.references, "Find References")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

          -- VS Code function keys (Shift+F12 arrives as <F24> in some terminals).
          -- F2 / F12 are global in lua/config/keymaps.lua (with a no-LSP fallback).
          local function references()
            require("telescope.builtin").lsp_references()
          end
          map("n", "<S-F12>", references, "Find All References (Shift+F12)")
          map("n", "<F24>", references, "Find All References (Shift+F12)")
          map("n", "<C-F12>", vim.lsp.buf.implementation, "Go to Implementation (Ctrl+F12)")
          -- Diagnostics keys ([d, ]d, <leader>d) are global, in lua/config/keymaps.lua
        end,
      })

      -- Modern Diagnostic styling (Neovim 0.10+ / 0.11+ / 0.12+)
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          spacing = 4,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = true,
        },
      })

      -- Server definitions and custom configurations
      local server_definitions = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = {
                checkThirdParty = false,
                library = {
                  [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                  [vim.fn.stdpath("config") .. "/lua"] = true,
                },
              },
              telemetry = { enable = false },
            },
          },
        },
        bashls = {},
        pyright = {},
        ts_ls = {},
        gopls = {},
        html = {},
        cssls = {},
        jsonls = {},
        yamlls = {},
        dockerls = {},
        terraformls = {},
      }

      -- Filetype to Server & Mason package mapping
      local ft_to_server = {
        python = { server = "pyright", package = "pyright", bin = "pyright-langserver" },
        sh = { server = "bashls", package = "bash-language-server", bin = "bash-language-server" },
        bash = { server = "bashls", package = "bash-language-server", bin = "bash-language-server" },
        javascript = { server = "ts_ls", package = "typescript-language-server", bin = "typescript-language-server" },
        typescript = { server = "ts_ls", package = "typescript-language-server", bin = "typescript-language-server" },
        javascriptreact = { server = "ts_ls", package = "typescript-language-server", bin = "typescript-language-server" },
        typescriptreact = { server = "ts_ls", package = "typescript-language-server", bin = "typescript-language-server" },
        lua = { server = "lua_ls", package = "lua-language-server", bin = "lua-language-server" },
        go = { server = "gopls", package = "gopls", bin = "gopls" },
        html = { server = "html", package = "html-lsp", bin = "vscode-html-language-server" },
        css = { server = "cssls", package = "css-lsp", bin = "vscode-css-language-server" },
        json = { server = "jsonls", package = "json-lsp", bin = "vscode-json-language-server" },
        jsonc = { server = "jsonls", package = "json-lsp", bin = "vscode-json-language-server" },
        yaml = { server = "yamlls", package = "yaml-language-server", bin = "yaml-language-server" },
        dockerfile = { server = "dockerls", package = "dockerfile-language-server", bin = "docker-langserver" },
        terraform = { server = "terraformls", package = "terraform-ls", bin = "terraform-ls" },
      }

      local enabled_servers = {}

      -- Function to activate a server cleanly without deprecation warnings
      local function enable_lsp_server(server_name)
        if enabled_servers[server_name] then
          return
        end

        local def = server_definitions[server_name] or {}
        local opts = vim.deepcopy(def)
        opts.capabilities = capabilities

        if is_nvim_011 then
          -- Neovim 0.11+ / 0.12+ native API
          vim.lsp.config(server_name, opts)
          vim.lsp.enable(server_name)
        else
          local ok_lsp, lspconfig = pcall(require, "lspconfig")
          if ok_lsp and lspconfig[server_name] then
            lspconfig[server_name].setup(opts)
          end
        end

        enabled_servers[server_name] = true
      end

      -- On-demand automatic installer & launcher triggered ONLY when a file is opened
      local installing_packages = {}

      local function check_and_start_lsp_for_buffer(bufnr)
        local ft = vim.bo[bufnr].filetype
        local target = ft_to_server[ft]
        if not target then
          return
        end

        -- Check if language server binary is already executable
        if vim.fn.executable(target.bin) == 1 then
          enable_lsp_server(target.server)
          return
        end

        -- If not installed, auto-install via Mason in the background on-demand
        local ok_registry, registry = pcall(require, "mason-registry")
        if not ok_registry or not registry.has_package(target.package) then
          return
        end

        if installing_packages[target.package] then
          return
        end

        local pkg = registry.get_package(target.package)
        if not pkg:is_installed() and not pkg:is_installing() then
          installing_packages[target.package] = true
          vim.notify(
            string.format("Auto-installing LSP for %s (%s)...", ft, target.package),
            vim.log.levels.INFO
          )

          pkg:install():once("closed", function()
            installing_packages[target.package] = nil
            vim.schedule(function()
              if pkg:is_installed() then
                vim.notify(
                  string.format("✓ %s ready! Starting LSP for %s...", target.package, ft),
                  vim.log.levels.INFO
                )
                enable_lsp_server(target.server)
                -- Trigger LSP attach for current buffer
                if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == ft then
                  vim.cmd("silent! checktime " .. bufnr)
                end
              end
            end)
          end)
        end
      end

      -- Autocommand: Check & start LSP ONLY for the active file's language
      local lsp_auto_group = vim.api.nvim_create_augroup("LspOnDemandAutoInstall", { clear = true })
      vim.api.nvim_create_autocmd({ "FileType", "BufReadPost" }, {
        group = lsp_auto_group,
        callback = function(args)
          check_and_start_lsp_for_buffer(args.buf)
        end,
      })
    end,
  },
}
