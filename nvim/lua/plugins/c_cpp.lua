local is_win = vim.fn.has("win32") == 1
local is_termux = vim.fn.isdirectory("/data/data/com.termux") == 1

local clangd_cmd
if is_win then
  clangd_cmd = {
    "C:/Users/bit/AppData/Local/nvim-data/clangd/clangd.exe",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders=true",
    "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
    "--query-driver=C:/Users/bit/AppData/Local/Microsoft/WinGet/Packages/BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe/mingw64/bin/g++.exe,**",
  }
else
  -- Linux / Termux: use system clangd from $PATH
  clangd_cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders=true",
    "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
  }
end

return {
  -- LSP Configuration for C & Colemak LSP key overrides
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        ["*"] = {
          keys = {
            -- Unbind default 'K' from hover so Colemak 'K' (End of WORD) remains untouched
            { "K", false },
            -- Map hover to 'gh' and '<leader>k'
            { "gh", vim.lsp.buf.hover, desc = "Hover Documentation" },
            { "<leader>k", vim.lsp.buf.hover, desc = "Hover Documentation" },
          },
        },
        clangd = {
          cmd = clangd_cmd,
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
            fallbackFlags = { "-std=c++23" },
          },
        },
      },
    },
  },

  -- Ensure Mason installs debugger (codelldb) and formatter (clang-format) on desktop only
  {
    "mason-org/mason.nvim",
    enabled = not is_termux,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb", "clang-format" })
    end,
  },
}
