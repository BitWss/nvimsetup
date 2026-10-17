return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>e",
        function()
          local bufpath = vim.api.nvim_buf_get_name(0)
          local dir
          if bufpath and bufpath ~= "" and vim.fn.filereadable(bufpath) == 1 then
            dir = vim.fs.root(bufpath, { ".git" }) or vim.fs.dirname(bufpath)
          else
            dir = LazyVim.root()
          end
          if dir:lower():find("system32") or dir:lower():find("program files\\neovim") then
            dir = vim.fs.normalize(vim.fn.expand("$HOME/Documents"))
          end
          require("neo-tree.command").execute({ toggle = true, dir = dir, reveal = true })
        end,
        desc = "Explorer NeoTree (Root / File Dir)",
      },
      {
        "<leader>E",
        function()
          local bufpath = vim.api.nvim_buf_get_name(0)
          local dir = (bufpath and bufpath ~= "" and vim.fn.filereadable(bufpath) == 1) and vim.fs.dirname(bufpath) or vim.uv.cwd()
          if dir:lower():find("system32") or dir:lower():find("program files\\neovim") then
            dir = vim.fs.normalize(vim.fn.expand("$HOME/Documents"))
          end
          require("neo-tree.command").execute({ toggle = true, dir = dir, reveal = true })
        end,
        desc = "Explorer NeoTree (Current File Dir)",
      },
      {
        "<leader>fe",
        function()
          local bufpath = vim.api.nvim_buf_get_name(0)
          local dir = (bufpath and bufpath ~= "" and vim.fn.filereadable(bufpath) == 1) and (vim.fs.root(bufpath, { ".git" }) or vim.fs.dirname(bufpath)) or LazyVim.root()
          if dir:lower():find("system32") or dir:lower():find("program files\\neovim") then
            dir = vim.fs.normalize(vim.fn.expand("$HOME/Documents"))
          end
          require("neo-tree.command").execute({ toggle = true, dir = dir, reveal = true })
        end,
        desc = "Explorer NeoTree (Root / File Dir)",
      },
      {
        "<leader>fE",
        function()
          local bufpath = vim.api.nvim_buf_get_name(0)
          local dir = (bufpath and bufpath ~= "" and vim.fn.filereadable(bufpath) == 1) and vim.fs.dirname(bufpath) or vim.uv.cwd()
          if dir:lower():find("system32") or dir:lower():find("program files\\neovim") then
            dir = vim.fs.normalize(vim.fn.expand("$HOME/Documents"))
          end
          require("neo-tree.command").execute({ toggle = true, dir = dir, reveal = true })
        end,
        desc = "Explorer NeoTree (Current File Dir)",
      },
    },
    opts = {
      commands = {
        smart_left = function(state)
          local tree = state.tree
          if not tree then
            return
          end
          local node = tree:get_node()
          if not node then
            return
          end

          -- 1. If it's an expanded folder, collapse it
          if node:has_children() and node:is_expanded() then
            node:collapse()
            require("neo-tree.ui.renderer").redraw(state)
            return
          end

          -- 2. If it's a file or collapsed folder, jump to parent folder
          local parent_id = node:get_parent_id()
          if parent_id then
            require("neo-tree.ui.renderer").focus_node(state, parent_id)
          else
            vim.cmd("normal! 0")
          end
        end,
        smart_right = function(state)
          local tree = state.tree
          if not tree then
            return
          end
          local node = tree:get_node()
          if not node then
            return
          end

          if node:has_children() then
            if not node:is_expanded() then
              node:expand()
              require("neo-tree.ui.renderer").redraw(state)
            else
              -- Focus first child if already expanded
              require("neo-tree.ui.renderer").focus_node(state, nil, true, 1)
            end
          else
            state.commands.open(state)
          end
        end,
      },
      window = {
        mappings = {
          -- Free up 'e' and 'i' for Colemak cursor movement (Down and Up)
          ["e"] = "none",
          ["i"] = "none",

          -- Colemak tree navigation (neio cluster):
          -- 'n' = Left (collapse folder / jump to parent folder)
          ["n"] = "smart_left",
          -- 'o' = Right (expand folder / enter / open file)
          ["o"] = "smart_right",

          -- Move displaced Neo-tree window actions
          ["E"] = "toggle_auto_expand_width",
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        window = {
          mappings = {
            -- Ensure e, i, n, o work consistently in filesystem view
            ["e"] = "none",
            ["i"] = "none",
            ["n"] = "smart_left",
            ["o"] = "smart_right",

            -- Free up displaced 'o' prefixes from default neo-tree
            ["oc"] = "none",
            ["od"] = "none",
            ["og"] = "none",
            ["om"] = "none",
            ["on"] = "none",
            ["os"] = "none",
            ["ot"] = "none",

            -- Move displaced filesystem actions
            ["I"] = "show_file_details",
            -- Remap "Order by" menu from 'o' to 'O'
            ["O"] = { "show_help", config = { prefix_key = "O", title = "Order by" } },
            ["Oc"] = "order_by_created",
            ["Od"] = "order_by_diagnostics",
            ["Og"] = "order_by_git_status",
            ["Om"] = "order_by_modified",
            ["On"] = "order_by_name",
            ["Os"] = "order_by_size",
            ["Ot"] = "order_by_type",
          },
        },
      },
    },
  },
}
