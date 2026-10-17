return {
  {
    "nvim-mini/mini.ai",
    opts = function(_, opts)
      opts = opts or {}
      opts.mappings = opts.mappings or {}
      -- Colemak-DH: 'i' is Move Up, so it cannot be the "inside" text object prefix.
      -- Remap text-object prefixes to use 'u' (inner):
      opts.mappings.inside = "u"
      opts.mappings.inside_next = "un"
      opts.mappings.inside_last = "ul"
      return opts
    end,
  },
}
