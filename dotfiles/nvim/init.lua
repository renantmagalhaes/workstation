-- Neovim Configuration (Custom, Robust & Stable)
-- Options are loaded first to configure leaders and basic behavior
require("config.options")

-- Bootstrap lazy.nvim and load plugins
require("config.lazy")

-- Keymaps and autocommands
require("config.keymaps")
require("config.autocmds")
