return {
  {
    "folke/snacks.nvim",
    opts = {
      scope = {
        keys = {
          textobject = {
            ii = false,
            ai = false,
            uu = {
              min_size = 2,
              edge = false,
              cursor = false,
              treesitter = { blocks = { enabled = false } },
              desc = "inner scope",
            },
            au = {
              cursor = false,
              min_size = 2,
              treesitter = { blocks = { enabled = false } },
              desc = "full scope",
            },
          },
          jump = {
            ["[i"] = false,
            ["]i"] = false,
            ["[u"] = {
              min_size = 2,
              bottom = false,
              cursor = false,
              edge = true,
              treesitter = { blocks = { enabled = false } },
              desc = "jump to top edge of scope",
            },
            ["]u"] = {
              min_size = 2,
              bottom = true,
              cursor = false,
              edge = true,
              treesitter = { blocks = { enabled = false } },
              desc = "jump to bottom edge of scope",
            },
          },
        },
      },
    },
  },
}
