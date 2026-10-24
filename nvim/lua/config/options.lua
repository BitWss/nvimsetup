-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- C / Low-Level Indentation Defaults (4 spaces)
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = false -- Disabled to prevent conflict with cindent
opt.shiftround = true   -- Always round indentation to multiples of shiftwidth (4 spaces)

-- Disable automatic format-on-save by default to prevent unwanted code reformatting and line deletion
vim.g.autoformat = false

-- Performance and editor feel
opt.scrolloff = 8
opt.updatetime = 250
opt.timeoutlen = 300
opt.termguicolors = true
opt.undofile = true

-- Termux / Android Clipboard Integration (sync with system clipboard)
if vim.fn.isdirectory("/data/data/com.termux") == 1 then
  if vim.fn.executable("termux-clipboard-get") == 1 then
    vim.g.clipboard = {
      name = "termux-clipboard",
      copy = {
        ["+"] = "termux-clipboard-set",
        ["*"] = "termux-clipboard-set",
      },
      paste = {
        ["+"] = "termux-clipboard-get",
        ["*"] = "termux-clipboard-get",
      },
      cache_enabled = 0,
    }
  end
end
