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

-- User command to instantly reset training.txt from training_master.txt
vim.api.nvim_create_user_command("TrainingReset", function()
  local dir = vim.fn.expand("%:p:h")
  local master = dir .. "/training_master.txt"
  if vim.fn.filereadable(master) == 1 then
    local content = vim.fn.readfile(master)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
    vim.cmd("write")
    vim.notify("Training playground successfully reset from master copy!", vim.log.levels.INFO, { title = "Vim Training Dojo" })
  else
    vim.notify("training_master.txt not found in directory: " .. dir, vim.log.levels.WARN, { title = "Vim Training Dojo" })
  end
end, { desc = "Reset training.txt from training_master.txt" })

-- Auto-correct CWD away from Windows System32 / Program Files when editing files
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Automatically change directory away from System32/Program Files",
  callback = function()
    local cwd = vim.uv.cwd():lower()
    if cwd:find("system32") or cwd:find("program files\\neovim") then
      local file = vim.api.nvim_buf_get_name(0)
      if file and file ~= "" and vim.fn.filereadable(file) == 1 then
        local dir = vim.fs.root(file, { ".git" }) or vim.fs.dirname(file)
        pcall(vim.cmd.cd, dir)
      end
    end
  end,
})

