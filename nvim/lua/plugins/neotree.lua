return {
  {
    "nvim-neo-tree/neo-tree.nvim",
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
