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
pcall(vim.keymap.del, "v", "J")
pcall(vim.keymap.del, "v", "K")
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
for _, mode in ipairs({ "n", "v", "o" }) do
  -- Core cursor movement (with count and wrapped line support)
  map(mode, "n", "h", { desc = "Move Left" })
  map(mode, "e", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move Down" })
  map(mode, "i", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move Up" })
  map(mode, "o", "l", { desc = "Move Right" })

  -- Displaced commands
  map(mode, "k", "e", { desc = "End of word" })
  map(mode, "K", "E", { desc = "End of WORD" })
  map(mode, "j", "n", { desc = "Next search match" })
  map(mode, "J", "N", { desc = "Previous search match" })
end

-- Insert Mode (u replaces i, matching physical QWERTY 'i' location on Colemak-DH)
map("n", "u", "i", { desc = "Insert mode" })
map("n", "U", "I", { desc = "Insert at beginning of line" })
map("v", "U", "I", { desc = "Block insert" })

-- Text object 'inner' in visual and operator-pending modes (e.g. cuw, duw, vuw)
map({ "o", "v" }, "u", "i", { desc = "Inner text object" })

-- Undo & Redo (z is physically the same key on Colemak-DH and QWERTY)
map({ "n", "v" }, "z", "u", { desc = "Undo" })
map({ "n", "v" }, "Z", "<C-r>", { desc = "Redo" })

-- Viewport / Screen Centering (replaces zz / zt / zb displaced by Colemak z = Undo)
map("n", "gz", "zz", { desc = "Center screen on cursor" })
map("n", "gzt", "zt", { desc = "Top screen on cursor" })
map("n", "gzb", "zb", { desc = "Bottom screen on cursor" })

-- Keep h/H as alternative Insert, and l/L for line creation
map("n", "h", "i", { desc = "Insert mode (alias)" })
map("n", "H", "I", { desc = "Insert at beginning of line (alias)" })
map("n", "l", "o", { desc = "Open line below" })
map("n", "L", "O", { desc = "Open line above" })
map("v", "h", "I", { desc = "Block insert (alias)" })

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

-- Quick Save & Clear Highlights
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>ch", "<cmd>nohlsearch<CR>", { desc = "Clear highlight" })

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

-- Compile single C/C++ file quickly and run it with cf-runner in a split terminal
local function cf_run_file()
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local fname = vim.fn.expand("%:t:r")
  local ext = vim.fn.expand("%:e"):lower()
  local is_win = vim.fn.has("win32") == 1

  -- Close any existing cf-runner terminal buffers so the previous .exe isn't locked
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local bname = vim.api.nvim_buf_get_name(buf)
      if bname:find("cf%-runner") or bname:find(fname .. "%.exe") then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
  end

  -- Ensure output directory exists in project folder
  local out_dir = dir .. (is_win and "\\output" or "/output")
  if vim.fn.isdirectory(out_dir) == 0 then
    vim.fn.mkdir(out_dir, "p")
  end

  local out_exe = out_dir .. (is_win and ("\\" .. fname .. ".exe") or ("/" .. fname))
  -- Remove previous binary before compiling so ld.exe creates a clean file
  pcall(vim.fn.delete, out_exe)

  local is_cpp = (ext == "cpp" or ext == "cc" or ext == "cxx")

  -- WinLibs GCC paths with C++23 flags
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
  local run_cmd = string.format('cf-runner "%s"', out_exe)
  local full_cmd = is_win and string.format('cd /d "%s" && %s && %s', dir, compile_cmd, run_cmd)
    or string.format('cd "%s" && %s && %s', dir, compile_cmd, run_cmd)

  vim.cmd("w")
  vim.cmd("botright split | resize 15 | terminal " .. full_cmd)
end

map("n", "<leader>cc", cf_run_file, { desc = "Compile & Run with cf-runner (C++23)" })
map("n", "<F6>", cf_run_file, { desc = "Compile & Run with cf-runner (F6)" })
map("i", "<F6>", function()
  vim.cmd("stopinsert")
  cf_run_file()
end, { desc = "Compile & Run with cf-runner (F6)" })

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

