-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ---------------------------------------------------------------------------
-- 1. Remove Conflicting LazyVim Default Mappings
-- ---------------------------------------------------------------------------
pcall(vim.keymap.del, "n", "<S-h>")
pcall(vim.keymap.del, "n", "<S-l>")
pcall(vim.keymap.del, "n", "H")
pcall(vim.keymap.del, "n", "L")
pcall(vim.keymap.del, "x", "J")
pcall(vim.keymap.del, "x", "K")
pcall(vim.keymap.del, "x", "in")
pcall(vim.keymap.del, "x", "an")
pcall(vim.keymap.del, "o", "in")
pcall(vim.keymap.del, "o", "an")
pcall(vim.keymap.del, "x", "ii")
pcall(vim.keymap.del, "x", "ai")
pcall(vim.keymap.del, "o", "ii")
pcall(vim.keymap.del, "o", "ai")
-- Ensure Select mode (snippets/tabstops) is 100% clean so typing printable keys replaces selection directly
for _, k in ipairs({ "n", "e", "i", "o", "k", "K", "j", "J", "u", "U", "z", "Z", "h", "H" }) do
  pcall(vim.keymap.del, "s", k)
end
pcall(vim.keymap.del, "n", "<leader>uh")
map("n", "<leader>uh", "<nop>", { desc = "Disabled (Inlay hints off)" })

-- ---------------------------------------------------------------------------
-- 2. Colemak-DH Custom Navigation Remaps ("neio")
-- ---------------------------------------------------------------------------
-- Movement:
--   n -> left  (replaces h)
--   e -> down  (replaces j)
--   i -> up    (replaces k)
--   o -> right (replaces l)
--
-- Displaced commands mapped to former navigation cluster:
--   h -> insert mode          (replaces i)
--   H -> insert at start      (replaces I)
--   j -> next search match    (replaces n)
--   J -> previous search      (replaces N)
--   k -> end of word          (replaces e)
--   K -> end of WORD          (replaces E)
--   l -> open line below      (replaces o)
--   L -> open line above      (replaces O)

-- Normal / Visual / Operator-pending mode: Movement & Displaced keys
-- NOTE: Use "x" (Visual only), NEVER "v" (Visual + Select)! Using "v" maps Select mode, which breaks snippet editing!
for _, mode in ipairs({ "n", "x", "o" }) do
  -- Core cursor movement (with count and wrapped line support)
  map(mode, "n", "h", { nowait = true, desc = "Move Left" })
  map(mode, "e", "v:count == 0 ? 'gj' : 'j'", { expr = true, nowait = true, desc = "Move Down" })
  map(mode, "i", "v:count == 0 ? 'gk' : 'k'", { expr = true, nowait = true, desc = "Move Up" })
  map(mode, "o", "l", { nowait = true, desc = "Move Right" })

  -- Displaced commands
  map(mode, "k", "e", { nowait = true, desc = "End of word" })
  map(mode, "K", "E", { nowait = true, desc = "End of WORD" })
  map(mode, "j", "n", { nowait = true, desc = "Next search match" })
  map(mode, "J", "N", { nowait = true, desc = "Previous search match" })
end

-- Insert Mode (u replaces i, matching physical QWERTY 'i' location on Colemak-DH)
map("n", "u", "i", { desc = "Insert mode" })
map("n", "U", "I", { desc = "Insert at beginning of line" })
map("x", "U", "I", { desc = "Block insert" })

-- Text object 'inner' in visual and operator-pending modes (e.g. cuw, duw, vuw)
map({ "o", "x" }, "u", "i", { desc = "Inner text object" })

-- Undo & Redo (z is physically the same key on Colemak-DH and QWERTY)
map({ "n", "x" }, "z", "u", { nowait = true, desc = "Undo" })
map({ "n", "x" }, "Z", "<C-r>", { nowait = true, desc = "Redo" })

-- Viewport / Screen Centering (replaces zz / zt / zb displaced by Colemak z = Undo)
map("n", "gzz", "zz", { desc = "Center screen on cursor" })
map("n", "gzt", "zt", { desc = "Top screen on cursor" })
map("n", "gzb", "zb", { desc = "Bottom screen on cursor" })

-- Keep h/H as alternative Insert, and l/L for line creation
map("n", "h", "i", { desc = "Insert mode (alias)" })
map("n", "H", "I", { desc = "Insert at beginning of line (alias)" })
map("n", "l", "o", { desc = "Open line below" })
map("n", "L", "O", { desc = "Open line above" })
map("x", "h", "I", { desc = "Block insert (alias)" })

-- Window Navigation (Ctrl-w + n/e/i/o)
map("n", "<C-w>n", "<C-w>h", { desc = "Window Left" })
map("n", "<C-w>e", "<C-w>j", { desc = "Window Down" })
map("n", "<C-w>i", "<C-w>k", { desc = "Window Up" })
map("n", "<C-w>o", "<C-w>l", { desc = "Window Right" })

-- Fast Window Splitting
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "Split horizontally" })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split vertically" })
map("n", "<leader>wd", "<cmd>close<CR>", { desc = "Close split" })

-- Buffer Navigation
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Quick Save, Clear Highlights & Dismiss Popups
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>ch", function()
  vim.cmd("nohlsearch")
  pcall(function() require("noice").cmd("dismiss") end)
end, { desc = "Clear highlights & dismiss popups" })
map("n", "<Esc>", function()
  vim.cmd("nohlsearch")
  pcall(function() require("noice").cmd("dismiss") end)
end, { desc = "Clear highlights & dismiss popups" })

-- LSP Hover (since 'K' is remapped to 'E' - End of WORD)
map("n", "gh", vim.lsp.buf.hover, { desc = "Hover Documentation" })
map("n", "<leader>k", vim.lsp.buf.hover, { desc = "Hover Documentation" })

-- ---------------------------------------------------------------------------
-- 3. C Build & Run Shortcuts
-- ---------------------------------------------------------------------------
-- Run :make using project Makefile
map("n", "<leader>m", "<cmd>make<CR>", { desc = "Run Make" })

-- Sequentially pre-warm Windows 11 Smart App Control ($KERNEL.PURGE.ESBCACHE)
-- for WinLibs GCC binaries/DLLs so ntdll's 4-thread parallel loader never fires
-- a burst of 9+ simultaneous Defender Cloud queries when the 24h TTL expires.
local last_warm_time = 0
local function warm_winlibs_smartlocker(mingw_root)
  if vim.fn.has("win32") ~= 1 then
    return
  end
  local now = vim.uv.now()
  -- Re-check at most once per 30 minutes within the same Neovim session
  if (now - last_warm_time) < (30 * 60 * 1000) then
    return
  end
  last_warm_time = now

  local ok, ffi = pcall(require, "ffi")
  if not ok then
    return
  end
  pcall(ffi.cdef, [[
    void* LoadLibraryExA(const char* lpLibFileName, void* hFile, uint32_t dwFlags);
    int FreeLibrary(void* hLibModule);
  ]])

  local libexec = mingw_root .. "/libexec/gcc/x86_64-w64-mingw32/16.2.0"
  local bin = mingw_root .. "/bin"
  local xbin = mingw_root .. "/x86_64-w64-mingw32/bin"

  local pipeline_files = {
    -- Core compiler driver & runtime DLLs in bin/
    bin .. "/libiconv-2.dll",
    bin .. "/libwinpthread-1.dll",
    bin .. "/libgcc_s_seh-1.dll",
    bin .. "/libstdc++-6.dll",
    bin .. "/g++.exe",
    bin .. "/gcc.exe",
    -- cc1plus / cc1 & their 9 statically imported DLLs in libexec/
    libexec .. "/libgmp-10.dll",
    libexec .. "/libiconv-2.dll",
    libexec .. "/libisl-23.dll",
    libexec .. "/libmpc-3.dll",
    libexec .. "/libmpfr-6.dll",
    libexec .. "/libgcc_s_seh-1.dll",
    libexec .. "/libwinpthread-1.dll",
    libexec .. "/libzstd.dll",
    libexec .. "/zlib1.dll",
    libexec .. "/cc1plus.exe",
    libexec .. "/cc1.exe",
    libexec .. "/collect2.exe",
    -- Assembler & linker in x86_64-w64-mingw32/bin/
    xbin .. "/libiconv-2.dll",
    xbin .. "/libintl-8.dll",
    xbin .. "/libwinpthread-1.dll",
    xbin .. "/libzstd.dll",
    xbin .. "/zlib1.dll",
    xbin .. "/as.exe",
    xbin .. "/ld.exe",
  }

  -- DONT_RESOLVE_DLL_REFERENCES (0x1) maps only the single PE image as SEC_IMAGE
  -- without running DllMain or triggering parallel dependency loading.
  for _, path in ipairs(pipeline_files) do
    local t0 = vim.uv.hrtime()
    local handle = ffi.C.LoadLibraryExA(path, nil, 1)
    if handle ~= nil then
      ffi.C.FreeLibrary(handle)
    end
    local elapsed_ms = (vim.uv.hrtime() - t0) / 1e6
    -- If a cloud reputation check occurred (>= 15ms), pace the next file by 150ms
    -- so Microsoft Defender Cloud never rate-limits or times out a burst.
    if elapsed_ms >= 15 then
      vim.uv.sleep(150)
    end
  end
end

-- Remember the last compiled C/C++ buffer so re-running from terminal window works seamlessly
local last_c_cpp_buf = nil

-- Compile single C/C++ file quickly and run it with cf-runner in a split terminal
local function cf_run_file()
  local cur_buf = vim.api.nvim_get_current_buf()
  local cur_file = vim.api.nvim_buf_get_name(cur_buf)
  local cur_ext = vim.fn.fnamemodify(cur_file, ":e"):lower()
  local is_c_cpp = (cur_ext == "cpp" or cur_ext == "cc" or cur_ext == "cxx" or cur_ext == "c")

  local target_buf = nil
  if is_c_cpp and vim.bo[cur_buf].buftype ~= "terminal" then
    target_buf = cur_buf
    last_c_cpp_buf = cur_buf
  elseif last_c_cpp_buf and vim.api.nvim_buf_is_valid(last_c_cpp_buf) then
    target_buf = last_c_cpp_buf
  else
    -- Search all windows in current tab for an open C/C++ file
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local b = vim.api.nvim_win_get_buf(win)
      local bname = vim.api.nvim_buf_get_name(b)
      local bext = vim.fn.fnamemodify(bname, ":e"):lower()
      if (bext == "cpp" or bext == "cc" or bext == "cxx" or bext == "c") and vim.bo[b].buftype ~= "terminal" then
        target_buf = b
        last_c_cpp_buf = b
        break
      end
    end
  end

  if not target_buf or not vim.api.nvim_buf_is_valid(target_buf) then
    vim.notify("No active C/C++ file found to compile.", vim.log.levels.WARN, { title = "Compile & Run" })
    return
  end

  local file = vim.api.nvim_buf_get_name(target_buf)
  local dir = vim.fn.fnamemodify(file, ":h")
  local fname = vim.fn.fnamemodify(file, ":t:r")
  local ext = vim.fn.fnamemodify(file, ":e"):lower()
  local is_win = vim.fn.has("win32") == 1
  local is_cpp = (ext == "cpp" or ext == "cc" or ext == "cxx")

  -- 1. Save the target source file
  pcall(vim.api.nvim_buf_call, target_buf, function()
    vim.cmd("w")
  end)

  -- 2. Terminate any previous terminal jobs and delete all terminal buffers
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "terminal" then
      local chan = vim.bo[b].channel
      if chan and chan > 0 then
        pcall(vim.fn.jobstop, chan)
      end
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end

  -- 3. Close any remaining terminal windows in the current tab to prevent stacked splits
  local current_tab = vim.api.nvim_get_current_tabpage()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(current_tab)) do
    local b = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(b) and vim.bo[b].buftype == "terminal" then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end

  -- 4. On Windows, kill any lingering binary AND cf-runner process so all file locks are released
  if is_win then
    pcall(vim.fn.system, string.format('taskkill /F /IM "%s.exe" /IM "cf-runner.exe" /T 2>nul', fname))
    vim.uv.sleep(50)
  end

  -- 5. Ensure output directory exists in project folder
  local out_dir = dir .. (is_win and "\\output" or "/output")
  if vim.fn.isdirectory(out_dir) == 0 then
    pcall(vim.fn.mkdir, out_dir, "p")
  end

  local out_exe = out_dir .. (is_win and ("\\" .. fname .. ".exe") or ("/" .. fname))
  -- Note: Do NOT call vim.fn.delete(out_exe). On Windows, deleting a freshly closed binary
  -- puts it into DELETE_PENDING state, which causes ERROR_ACCESS_DENIED when g++ tries to write it.
  -- g++ / ld.exe will safely overwrite it.

  -- 6. WinLibs GCC paths with C++23 flags
  local mingw_root = "C:/Users/bit/AppData/Local/Microsoft/WinGet/Packages/BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe/mingw64"
  local winlibs_gpp = mingw_root .. "/bin/g++.exe"
  local winlibs_gcc = mingw_root .. "/bin/gcc.exe"

  if is_win and vim.fn.isdirectory(mingw_root) == 1 then
    warm_winlibs_smartlocker(mingw_root)
  end

  local compiler
  if is_cpp then
    compiler = vim.fn.filereadable(winlibs_gpp) == 1 and ('"' .. winlibs_gpp .. '"') or "g++"
  else
    compiler = vim.fn.filereadable(winlibs_gcc) == 1 and ('"' .. winlibs_gcc .. '"') or "gcc"
  end

  local flags = is_cpp and "-std=c++23 -O2 -fno-lto -Wall -Wextra -DLOCAL" or "-O2 -fno-lto -Wall -Wextra -DLOCAL"

  local compile_cmd = string.format('%s %s "%s" -o "%s"', compiler, flags, file, out_exe)
  -- On Windows, give 30ms via ping between compile and run so ld.exe handle release and antivirus scan settle
  local run_cmd = is_win and string.format('(ping -n 1 127.0.0.1 >nul) && cf-runner "%s"', out_exe)
    or string.format('cf-runner "%s"', out_exe)
  local full_cmd = is_win and string.format('cd /d "%s" && %s && %s', dir, compile_cmd, run_cmd)
    or string.format('cd "%s" && %s && %s', dir, compile_cmd, run_cmd)

  -- 7. Open single bottom terminal split and enter insert mode immediately
  vim.cmd("botright split | resize 15 | terminal " .. full_cmd)
  vim.cmd("startinsert")
end

map("n", "<leader>cc", cf_run_file, { desc = "Compile & Run with cf-runner (C++23)" })
map("n", "<F6>", cf_run_file, { desc = "Compile & Run with cf-runner (F6)" })
map("i", "<F6>", function()
  vim.cmd("stopinsert")
  cf_run_file()
end, { desc = "Compile & Run with cf-runner (F6)" })

-- Terminal Mode: Instant Paste via nvim_paste (bypasses Windows ConPTY per-character redraw lag)
map("t", "<C-v>", function()
  local text = vim.fn.getreg("+")
  if text and text ~= "" then
    vim.api.nvim_paste(text, true, -1)
  end
end, { desc = "Instant Paste into Terminal" })

map("t", "<C-S-v>", function()
  local text = vim.fn.getreg("+")
  if text and text ~= "" then
    vim.api.nvim_paste(text, true, -1)
  end
end, { desc = "Instant Paste into Terminal" })

-- Normal mode in terminal: pressing 'p' enters insert and pastes instantly
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("TerminalInstantPaste", { clear = true }),
  callback = function(ev)
    vim.keymap.set("n", "p", function()
      local text = vim.fn.getreg("+")
      if text and text ~= "" then
        vim.cmd("startinsert")
        vim.api.nvim_paste(text, true, -1)
      end
    end, { buffer = ev.buf, desc = "Instant Paste into Terminal" })
  end,
})

-- ---------------------------------------------------------------------------
-- 4. Instant Visual Surround (Wrap selected text in (), [], {}, "", '')
-- ---------------------------------------------------------------------------
local function wrap_selection(open_delim, close_delim)
  return function()
    local reg_save = vim.fn.getreg('"')
    local reg_type = vim.fn.getregtype('"')
    vim.cmd('normal! "zd')
    local text = vim.fn.getreg('z')
    local z_type = vim.fn.getregtype('z')

    if z_type == 'V' then
      local had_newline = text:sub(-1) == "\n"
      if had_newline then text = text:sub(1, -2) end
      vim.fn.setreg('z', open_delim .. "\n" .. text .. "\n" .. close_delim .. (had_newline and "\n" or ""), 'V')
    else
      vim.fn.setreg('z', open_delim .. text .. close_delim, 'c')
    end
    vim.cmd('normal! "zP')
    vim.fn.setreg('"', reg_save, reg_type)
  end
end

-- 1-Keystroke Visual Wrappers: select text, press symbol to wrap!
map("x", "(", wrap_selection("(", ")"), { desc = "Surround with ()" })
map("x", ")", wrap_selection("(", ")"), { desc = "Surround with ()" })
map("x", "[", wrap_selection("[", "]"), { desc = "Surround with []" })
map("x", "]", wrap_selection("[", "]"), { desc = "Surround with []" })
map("x", "{", wrap_selection("{ ", " }"), { desc = "Surround with {  }" })
map("x", "}", wrap_selection("{", "}"), { desc = "Surround with {}" })
map("x", '"', wrap_selection('"', '"'), { desc = 'Surround with ""' })
map("x", "'", wrap_selection("'", "'"), { desc = "Surround with ''" })
map("x", "`", wrap_selection("`", "`"), { desc = "Surround with ``" })
map("x", "<", wrap_selection("<", ">"), { desc = "Surround with <>" })
map("x", ">", wrap_selection("<", ">"), { desc = "Surround with <>" })

-- Re-apply on VeryLazy to ensure no LazyVim defaults or plugins override our mappings
if not vim.g._colemak_keymaps_autocmd_set then
  vim.g._colemak_keymaps_autocmd_set = true
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      package.loaded["config.keymaps"] = nil
      require("config.keymaps")
    end,
  })
end


