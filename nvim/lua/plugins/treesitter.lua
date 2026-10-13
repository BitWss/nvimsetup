return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Disable automatic parser installation to prevent Windows Application Control blocks
      opts.ensure_installed = {}
      opts.auto_install = false
    end,
  },
}
