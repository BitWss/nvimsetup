return {
  {
    "folke/which-key.nvim",
    opts = {
      plugins = {
        presets = {
          -- In Colemak-DH: 'i' is Move Up and 'z' is Undo.
          -- Disable default QWERTY text_objects ('i' prefix) and 'z' presets so which-key
          -- never waits or causes a delay on 'i' or 'z'!
          text_objects = false,
          z = false,
        },
      },
    },
  },
}
