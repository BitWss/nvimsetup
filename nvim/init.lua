-- Set MSYS2 as the priority in PATH for Neovim
vim.env.PATH = "C:/msys64/ucrt64/bin;" .. vim.env.PATH

vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Colemak user keymaps for Neovim (Lua)
local map = vim.keymap.set

map({'n', 'v'}, 'd', 'c', { noremap = true })
map({'n', 'v'}, 'e', 'k', { noremap = true })
map({'n', 'v'}, 'f', 'e', { noremap = true })
map({'n', 'v'}, 'i', 'l', { noremap = true })
map({'n', 'v'}, 'j', 'y', { noremap = true })
map({'n', 'v'}, 'k', 'n', { noremap = true })
map('n', 'K', 'N', { noremap = true })
map({'n', 'v'}, 'l', 'u', { noremap = true })
map({'n', 'v'}, 'n', 'j', { noremap = true })
map({'n', 'v'}, 'o', ';', { noremap = true })
map({'n', 'v'}, 'p', 'r', { noremap = true })
map({'n', 'v'}, 'r', 's', { noremap = true })
map({'n', 'v'}, 's', '"_d', { noremap = true })
map('n', 'ss', '"_dd', { noremap = true, silent = true })
map({'n', 'v'}, 't', 'f', { noremap = true })
map({'n', 'v'}, 'u', 'i', { noremap = true })
map({'n', 'v'}, 'y', 'o', { noremap = true })
map({'n', 'v'}, 'm', 'h', { noremap = true })
map({'n', 'v'}, ';', 'p', { noremap = true })
map({'n', 'v'}, 'ss', 'dd', { noremap = true })
map('n', 'dd', 'cc', { noremap = true })
map('n', 'gt', 'gf', { noremap = true, silent = true })

-- Use MSYS2 Bash for shell commands in Neovim
vim.o.shell = "C:/msys64/usr/bin/bash.exe"
vim.o.shellcmdflag = "-c"
vim.o.shellxquote = "("
vim.o.shellslash = true
vim.o.shelltemp = false
