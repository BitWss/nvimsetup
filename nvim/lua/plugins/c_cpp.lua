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
          cmd = {
            "C:/Users/bit/AppData/Local/nvim-data/clangd/clangd.exe",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders=true",
            "--fallback-style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
            "--query-driver=C:/Users/bit/AppData/Local/Microsoft/WinGet/Packages/BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe/mingw64/bin/g++.exe,**",
          },
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


  -- Ensure Mason installs debugger (codelldb) and formatter (clang-format)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "codelldb", "clang-format" })
    end,
  },
}
