-- Use NvChad's default on_attach, on_init, and capabilities
local default_on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local lspconfig = require "lspconfig"

-- Custom on_attach to remap diagnostics to 'k'
local function on_attach(client, bufnr)
  default_on_attach(client, bufnr)
  -- Unmap default 'K' (hover)
  vim.keymap.set("n", "K", "<Nop>", { buffer = bufnr })
  -- Map 'k' (Colemak-DH) to show diagnostics in a floating window
  vim.keymap.set("n", "k", vim.diagnostic.open_float, { buffer = bufnr, desc = "Show diagnostics" })
end

-- Setup clangd for C++ with MSYS2
lspconfig.clangd.setup {
  cmd = {
    "C:/msys64/mingw64/bin/clangd.exe",
    "--query-driver=C:/msys64/mingw64/bin/g++.exe"
  },
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}
