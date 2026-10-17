-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load Colemak-DH keymaps immediately so navigation is available from frame 0
pcall(require, "config.keymaps")
