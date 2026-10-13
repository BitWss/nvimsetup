return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      debounce_delay = 1500, -- 1.5s delay after leaving insert mode or normal mode edit
      write_all_buffers = false,
      noautocmd = true, -- Silently write buffer without triggering BufWritePre (prevents spasm, line stripping & unwanted formatting)
      lockmarks = false,
      condition = function(buf)
        -- Only save modifiable and non-readonly buffers
        if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
          return false
        end

        -- Only save normal file buffers (skip terminal, help, quickfix, nofile, etc.)
        if vim.bo[buf].buftype ~= "" then
          return false
        end

        -- Must have a valid file path on disk
        local bufname = vim.api.nvim_buf_get_name(buf)
        if bufname == "" then
          return false
        end

        -- Exclude special UI and git commit filetypes
        local excluded_filetypes = {
          "gitcommit",
          "gitrebase",
          "neo-tree",
          "TelescopePrompt",
          "fzf",
          "lazy",
          "mason",
          "trouble",
        }
        if vim.tbl_contains(excluded_filetypes, vim.bo[buf].filetype) then
          return false
        end

        return true
      end,
    },
    keys = {
      { "<leader>uv", "<cmd>ASToggle<CR>", desc = "Toggle Auto-Save" },
    },
  },
}
