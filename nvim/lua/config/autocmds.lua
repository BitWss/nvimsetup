-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- C / C++ Style & Indentation (Strict 4 spaces matching Enter, Tab, and clang-format)
vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWinEnter" }, {
  pattern = { "c", "cpp" },
  callback = function()
    local filepath = vim.fn.expand("%:p")
    if filepath:match("linux") or filepath:match("kernel") or filepath:match("driver") then
      vim.opt_local.tabstop = 8
      vim.opt_local.shiftwidth = 8
      vim.opt_local.softtabstop = 8
      vim.opt_local.expandtab = false
    else
      vim.opt_local.tabstop = 4
      vim.opt_local.shiftwidth = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.expandtab = true
      vim.opt_local.smartindent = false
      vim.opt_local.cindent = true
      vim.opt_local.cinoptions = "g0,:0,N-s,(0"
    end
  end,
})
