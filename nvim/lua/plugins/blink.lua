local recent_completions = {
  ["std::string"] = 10,
  ["std::vector"] = 10,
  ["std::cin"] = 10,
  ["std::cout"] = 10,
}
local recency_counter = 10

-- Hook accept_emitter once blink loads to track last-used choices dynamically
local hook_registered = false
local function ensure_accept_hook()
  if hook_registered then
    return
  end
  local ok, list = pcall(require, "blink.cmp.completion.list")
  if ok and list and list.accept_emitter then
    list.accept_emitter:on(function(ev)
      if ev and ev.item and ev.item.label then
        recency_counter = recency_counter + 1
        recent_completions[ev.item.label] = recency_counter
        local unqualified = ev.item.label:gsub("^std::", "")
        if unqualified ~= ev.item.label then
          recent_completions[unqualified] = recency_counter
        end
      end
    end)
    hook_registered = true
  end
end

return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      vim.schedule(ensure_accept_hook)

      opts = opts or {}
      opts.fuzzy = opts.fuzzy or {}
      opts.fuzzy.implementation = "prefer_rust_with_warning"
      opts.fuzzy.sorts = {
        -- 1. Dynamically boost most recently chosen / used items to the top (MRU)
        function(a, b)
          local a_rank = recent_completions[a.label] or 0
          local b_rank = recent_completions[b.label] or 0
          if a_rank ~= b_rank then
            return a_rank > b_rank
          end
        end,
        -- 2. Demote obscure literal namespaces (e.g. std::string_literals)
        function(a, b)
          local a_lit = a.label:find("_literals$") ~= nil
          local b_lit = b.label:find("_literals$") ~= nil
          if a_lit ~= b_lit then
            return not a_lit
          end
        end,
        "exact",
        "score",
        "sort_text",
      }

      opts.keymap = opts.keymap or {}
      opts.keymap.preset = "super-tab"
      opts.keymap["<CR>"] = { "fallback" }

      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}

      opts.sources.providers.lsp = opts.sources.providers.lsp or {}
      opts.sources.providers.lsp.transform_items = function(ctx, items)
        for _, item in ipairs(items) do
          local label = item.label or ""
          -- Only transform if not already qualified with std:: or ::
          if not label:find("^std::") and not label:find("^::") then
            local detail = (item.detail or ""):lower()
            local doc = ""
            if type(item.documentation) == "string" then
              doc = item.documentation:lower()
            elseif type(item.documentation) == "table" and item.documentation.value then
              doc = item.documentation.value:lower()
            end

            -- Check if from a standard library header
            local is_std_header = detail:match("<c%w+>")
              or detail:match("<%w+>")
              or doc:match("<c%w+>")

            -- Standard library C functions that clangd imports into global scope without 'std::'
            local is_std_func = label:match("^(abs)%b()")
              or label:match("^(div)%b()")
              or label:match("^(labs)%b()")
              or label:match("^(llabs)%b()")
              or label:match("^(fabs)%b()")
              or label:match("^(sin)%b()")
              or label:match("^(cos)%b()")
              or label:match("^(tan)%b()")
              or label:match("^(asin)%b()")
              or label:match("^(acos)%b()")
              or label:match("^(atan)%b()")
              or label:match("^(atan2)%b()")
              or label:match("^(sinh)%b()")
              or label:match("^(cosh)%b()")
              or label:match("^(tanh)%b()")
              or label:match("^(exp)%b()")
              or label:match("^(log)%b()")
              or label:match("^(log10)%b()")
              or label:match("^(pow)%b()")
              or label:match("^(sqrt)%b()")
              or label:match("^(ceil)%b()")
              or label:match("^(floor)%b()")
              or label:match("^(fmod)%b()")
              or label:match("^(round)%b()")
              or label:match("^(trunc)%b()")
              or label:match("^(hypot)%b()")
              or label:match("^(exit)%b()")
              or label:match("^(abort)%b()")
              or label:match("^(qsort)%b()")
              or label:match("^(bsearch)%b()")
              or label:match("^(rand)%b()")
              or label:match("^(srand)%b()")
              or label:match("^(memcpy)%b()")
              or label:match("^(memmove)%b()")
              or label:match("^(memset)%b()")
              or label:match("^(memcmp)%b()")
              or label:match("^(strlen)%b()")
              or label:match("^(strcpy)%b()")
              or label:match("^(strncpy)%b()")
              or label:match("^(strcmp)%b()")
              or label:match("^(strncmp)%b()")
              or label:match("^(strchr)%b()")
              or label:match("^(strstr)%b()")
              or label:match("^(printf)%b()")
              or label:match("^(sprintf)%b()")
              or label:match("^(snprintf)%b()")
              or label:match("^(scanf)%b()")
              or label:match("^(sscanf)%b()")
              or label:match("^(isalpha)%b()")
              or label:match("^(isdigit)%b()")
              or label:match("^(isalnum)%b()")
              or label:match("^(isspace)%b()")
              or label:match("^(isupper)%b()")
              or label:match("^(islower)%b()")
              or label:match("^(toupper)%b()")
              or label:match("^(tolower)%b()")
              or label:match("^(min)%b()")
              or label:match("^(max)%b()")
              or label:match("^(swap)%b()")
              or label:match("^(clamp)%b()")
              or label:match("^(gcd)%b()")
              or label:match("^(lcm)%b()")

            if is_std_func or (is_std_header and label:match("^%a[%w_]*%b()")) then
              item.label = "std::" .. label
              if item.textEdit then
                if item.textEdit.newText and not item.textEdit.newText:find("^std::") then
                  item.textEdit.newText = "std::" .. item.textEdit.newText
                end
              elseif item.insertText then
                if not item.insertText:find("^std::") then
                  item.insertText = "std::" .. item.insertText
                end
              end
            end
          end
        end
        return items
      end

      opts.sources.providers.snippets = opts.sources.providers.snippets or {}
      opts.sources.providers.snippets.score_offset = 5
      opts.sources.providers.snippets.opts = {
        search_paths = {
          vim.fn.stdpath("config") .. "/snippets",
          vim.fn.expand("$APPDATA/Code/User/snippets"),
        },
      }
      opts.sources.providers.snippets.transform_items = function(ctx, items)
        local line_nr = ctx.cursor[1]
        local filtered = {}
        for _, item in ipairs(items) do
          if item.label == "cp" or item.label == "cp1" then
            if line_nr <= 3 then
              item.score_offset = 100
              table.insert(filtered, item)
            end
          else
            table.insert(filtered, item)
          end
        end
        return filtered
      end

      return opts
    end,
  },
}
