local function clean_label(label)
  if not label then return "" end
  return (label:gsub("^[•·* \t]+", ""):gsub("[ \t]+$", ""))
end

local function clean_text(text)
  if not text then return "" end
  return (text:gsub("%$%b{}", ""):gsub("%$%d+", ""):gsub("^[•·* \t]+", ""):gsub("[ \t]+$", ""))
end

local function is_obscure_subnamespace(item)
  local c = clean_label(item.label)
  if c:find("::pmr::") or c:find("::range_format::") or c:find("::experimental::") or c:find("_literals$") then
    return true
  end
  return false
end

local mru_file = vim.fn.stdpath("state") .. "/blink_mru.json"
local recent_completions = {}
local recency_counter = 100

local default_seeds = {
  ["std::string"] = 100,
  ["string"] = 100,
  ["std::vector"] = 90,
  ["vector"] = 90,
  ["std::cin"] = 80,
  ["cin"] = 80,
  ["std::cout"] = 80,
  ["cout"] = 80,
  ["std::endl"] = 70,
  ["endl"] = 70,
  ["std::min"] = 70,
  ["min"] = 70,
  ["std::max"] = 70,
  ["max"] = 70,
  ["std::swap"] = 70,
  ["swap"] = 70,
  ["std::pair"] = 60,
  ["pair"] = 60,
  ["std::map"] = 60,
  ["map"] = 60,
  ["std::set"] = 60,
  ["set"] = 60,
  ["std::queue"] = 60,
  ["queue"] = 60,
  ["std::stack"] = 60,
  ["stack"] = 60,
  ["std::sort"] = 60,
  ["sort"] = 60,
}

for k, v in pairs(default_seeds) do
  recent_completions[k] = v
end

local function load_mru()
  if vim.fn.filereadable(mru_file) == 1 then
    local content = table.concat(vim.fn.readfile(mru_file), "\n")
    local ok, data = pcall(vim.json.decode, content)
    if ok and type(data) == "table" and data.items then
      recency_counter = math.max(recency_counter, data.counter or 100)
      for k, v in pairs(data.items) do
        recent_completions[k] = v
      end
    end
  end
end

load_mru()

local save_timer = nil
local function save_mru()
  if save_timer then
    save_timer:stop()
  else
    save_timer = vim.uv.new_timer()
  end
  save_timer:start(300, 0, vim.schedule_wrap(function()
    local dir = vim.fs.dirname(mru_file)
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
    local data = {
      counter = recency_counter,
      items = recent_completions,
    }
    local ok, json_str = pcall(vim.json.encode, data)
    if ok and json_str then
      vim.fn.writefile({ json_str }, mru_file)
    end
  end))
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local dir = vim.fs.dirname(mru_file)
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
    local data = {
      counter = recency_counter,
      items = recent_completions,
    }
    local ok, json_str = pcall(vim.json.encode, data)
    if ok and json_str then
      pcall(vim.fn.writefile, { json_str }, mru_file)
    end
  end,
})

local function record_item(item)
  if not item then return end
  recency_counter = recency_counter + 1

  local keys = {}
  local l = clean_label(item.label)
  if #l > 0 then table.insert(keys, l) end

  local new_t = clean_text((item.textEdit and item.textEdit.newText) or item.insertText)
  if #new_t > 0 and new_t ~= l then table.insert(keys, new_t) end

  for _, k in ipairs(vim.deepcopy(keys)) do
    local base = k:gsub("%b<>$", ""):gsub("%b()$", "")
    if #base > 0 and base ~= k then table.insert(keys, base) end
    local unq = k:gsub("^std::", "")
    if #unq > 0 and unq ~= k then table.insert(keys, unq) end
  end

  for _, k in ipairs(keys) do
    recent_completions[k] = recency_counter
  end

  save_mru()
end

local function get_mru_score(item)
  local l = clean_label(item.label)
  if recent_completions[l] then return recent_completions[l] end

  local new_t = clean_text((item.textEdit and item.textEdit.newText) or item.insertText)
  if recent_completions[new_t] then return recent_completions[new_t] end

  local base = l:gsub("%b<>$", ""):gsub("%b()$", "")
  if recent_completions[base] then return recent_completions[base] end

  local unq = l:gsub("^std::", "")
  if recent_completions[unq] then return recent_completions[unq] end

  return 0
end

local hook_registered = false
local function ensure_accept_hook()
  if hook_registered then
    return
  end
  hook_registered = true

  -- Neovim User BlinkCmpAccept Autocmd
  vim.api.nvim_create_autocmd("User", {
    pattern = "BlinkCmpAccept",
    callback = function(ev)
      local item = ev.data and ev.data.item
      if item then
        record_item(item)
      end
    end,
  })

  -- Blink completion list accept_emitter
  local ok, list = pcall(require, "blink.cmp.completion.list")
  if ok and list and list.accept_emitter then
    list.accept_emitter:on(function(ev)
      if ev and ev.item then
        record_item(ev.item)
      end
    end)
  end
end

-- Initialize accept hook immediately
ensure_accept_hook()

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
          local a_mru = get_mru_score(a)
          local b_mru = get_mru_score(b)
          if a_mru ~= b_mru then
            return a_mru > b_mru
          end
        end,
        -- 2. Demote obscure sub-namespaces (std::pmr::, std::range_format::, std::experimental::, literals)
        function(a, b)
          local a_obs = is_obscure_subnamespace(a)
          local b_obs = is_obscure_subnamespace(b)
          if a_obs ~= b_obs then
            return not a_obs
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
          local c_label = clean_label(label)
          -- Only transform if not already qualified with std:: or ::
          if not c_label:find("^std::") and not c_label:find("^::") then
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
            local is_std_func = c_label:match("^(abs)%b()")
              or c_label:match("^(div)%b()")
              or c_label:match("^(labs)%b()")
              or c_label:match("^(llabs)%b()")
              or c_label:match("^(fabs)%b()")
              or c_label:match("^(sin)%b()")
              or c_label:match("^(cos)%b()")
              or c_label:match("^(tan)%b()")
              or c_label:match("^(asin)%b()")
              or c_label:match("^(acos)%b()")
              or c_label:match("^(atan)%b()")
              or c_label:match("^(atan2)%b()")
              or c_label:match("^(sinh)%b()")
              or c_label:match("^(cosh)%b()")
              or c_label:match("^(tanh)%b()")
              or c_label:match("^(exp)%b()")
              or c_label:match("^(log)%b()")
              or c_label:match("^(log10)%b()")
              or c_label:match("^(pow)%b()")
              or c_label:match("^(sqrt)%b()")
              or c_label:match("^(ceil)%b()")
              or c_label:match("^(floor)%b()")
              or c_label:match("^(fmod)%b()")
              or c_label:match("^(round)%b()")
              or c_label:match("^(trunc)%b()")
              or c_label:match("^(hypot)%b()")
              or c_label:match("^(exit)%b()")
              or c_label:match("^(abort)%b()")
              or c_label:match("^(qsort)%b()")
              or c_label:match("^(bsearch)%b()")
              or c_label:match("^(rand)%b()")
              or c_label:match("^(srand)%b()")
              or c_label:match("^(memcpy)%b()")
              or c_label:match("^(memmove)%b()")
              or c_label:match("^(memset)%b()")
              or c_label:match("^(memcmp)%b()")
              or c_label:match("^(strlen)%b()")
              or c_label:match("^(strcpy)%b()")
              or c_label:match("^(strncpy)%b()")
              or c_label:match("^(strcmp)%b()")
              or c_label:match("^(strncmp)%b()")
              or c_label:match("^(strchr)%b()")
              or c_label:match("^(strstr)%b()")
              or c_label:match("^(printf)%b()")
              or c_label:match("^(sprintf)%b()")
              or c_label:match("^(snprintf)%b()")
              or c_label:match("^(scanf)%b()")
              or c_label:match("^(sscanf)%b()")
              or c_label:match("^(isalpha)%b()")
              or c_label:match("^(isdigit)%b()")
              or c_label:match("^(isalnum)%b()")
              or c_label:match("^(isspace)%b()")
              or c_label:match("^(isupper)%b()")
              or c_label:match("^(islower)%b()")
              or c_label:match("^(toupper)%b()")
              or c_label:match("^(tolower)%b()")
              or c_label:match("^(min)%b()")
              or c_label:match("^(max)%b()")
              or c_label:match("^(swap)%b()")
              or c_label:match("^(clamp)%b()")
              or c_label:match("^(gcd)%b()")
              or c_label:match("^(lcm)%b()")

            if is_std_func or (is_std_header and c_label:match("^%a[%w_]*%b()")) then
              local prefix = label:match("^[•·* \t]+") or ""
              item.label = prefix .. "std::" .. c_label
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
