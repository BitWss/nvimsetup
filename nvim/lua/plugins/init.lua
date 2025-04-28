return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure opts is a table
      opts.ensure_installed = opts.ensure_installed or {}
      -- Add C and C++ to the ensure_installed list
      vim.list_extend(opts.ensure_installed, { "c", "cpp" })
    end,
  },
}
