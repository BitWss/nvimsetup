return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      open_mapping = [[<leader>t]], -- Space+t to toggle terminal
      direction = "horizontal",     -- or "float", "vertical", etc.
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      close_on_exit = true,
      shell = vim.o.shell,
    },
  },
}
