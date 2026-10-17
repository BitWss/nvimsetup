return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        signature = {
          -- Disable automatic popups when typing function arguments/parentheses
          -- Signature help can still be opened manually with <C-k> in insert mode
          auto_open = {
            enabled = false,
            trigger = false,
            luasnip = false,
          },
        },
      },
      views = {
        hover = {
          size = {
            max_height = 10, -- Limit popup height so it never covers the entire screen
            max_width = 80,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
      },
    },
  },
}
