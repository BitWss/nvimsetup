# Neovim (LazyVim) C/C++ & Colemak-DH Environment Setup

This document details the complete environment setup, configurations, shortcuts, toolchain, and troubleshooting fixes for C/C++ development in Neovim with the Colemak-DH (`neio`) layout.

---

## 1. Toolchain & Compilers

* **Primary Compiler Suite:** WinLibs GCC / MinGW-w64 (UCRT, 64-bit)
  * **Path:** `C:\Users\bit\AppData\Local\Microsoft\WinGet\Packages\BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\bin\g++.exe`
  * **Standards:** **C++23** (`-std=c++23 -O2 -fno-lto -static -Wall -Wextra -DLOCAL`), **C17** (`-O2 -fno-lto -static -Wall -Wextra -DLOCAL`)
  * **Secondary Suite:** LLVM-MinGW (UCRT, 64-bit) for Clang/LLDB tooling
* **Language Server (LSP):** LLVM **`clangd`** (`C:\Program Files\LLVM\bin\clangd.exe`)
  * Configured with `--query-driver` pointing to WinLibs `g++.exe` and global compile flags in `%LOCALAPPDATA%\clangd\config.yaml` for system C++23 standard headers (`<iostream>`, `<vector>`, `<string>`, `<algorithm>`, etc.).
  * Enhanced with `clangd_extensions.nvim` (AST hierarchy, memory layout, source/header switching via `<leader>c<Tab>`).
* **Code Formatter:** LLVM **`clang-format`**
  * Integrated through `conform.nvim` (`<leader>cf` or `<leader>f`).
* **Debugger (DAP):** **`codelldb`**
  * Integrated with `nvim-dap`, `nvim-dap-ui`, and `nvim-dap-virtual-text`.
* **Completion Engine:** **`blink.cmp`**
  * Super-Tab keymap: <kbd>Tab</kbd> accepts autocomplete suggestions and jumps through snippet tabstops; <kbd>Enter</kbd> inserts a newline without accepting completions.
  * Snippet templates: `cp` and `cp1` are context-filtered so they only appear at the very start of a file (lines 1–3) when typing `cp`, preventing them from cluttering suggestions when writing logic inside functions.

---

## 2. Automated Testing Workflow (`cf-runner` & `input.txt`)

Automated testing is powered by **`cf-runner.exe`** integrated with Neovim:

### Quick Compile & Run (**`<F6>`** or **`<leader>cc`**)
When working on a `.c` or `.cpp` file in Neovim:

* **Shortcuts:** Press **`<F6>`** (works in Normal and Insert modes) or **`<leader>cc`**
* **How It Works:**
  1. Auto-saves the current file.
  2. Compiles binary into `output/<filename>.exe` using WinLibs GCC with flags:
     ```text
     -std=c++23 -O2 -fno-lto -static -Wall -Wextra -DLOCAL
     ```
  3. Launches the binary via `cf-runner "output/<filename>.exe"` in a bottom split terminal:
     * **If `input.txt` exists and has content:** Pipes `input.txt` into standard input, measures execution time (ms), and tracks peak memory (KB).
     * **If `input.txt` does not exist or is empty:** Falls back to interactive console mode for manual typing.

### Makefile Projects (`<leader>m`)
* Press **`<leader>m`** to run `:make` in the current project directory.

### Interactive Debugging (`nvim-dap`)
* **`<leader>db`** - Toggle breakpoint on current line
* **`<leader>dc`** - Start or continue debugging session
* **`<leader>di`** - Step into function
* **`<leader>dO`** - Step over line
* **`<leader>do`** - Step out of function
* **`<leader>du`** - Toggle DAP UI (variables, watches, call stack, breakpoints)
* **`<leader>dt`** - Terminate debug session

---

## 3. Colemak-DH Keybindings Guide

The entire navigation and editing system is tailored for **Colemak-DH**:

### Core Cursor Movement (`neio`)
* **`n`** &rarr; Move Left (replaces `h`)
* **`e`** &rarr; Move Down (replaces `j`, supports `count` and wrapped lines)
* **`i`** &rarr; Move Up (replaces `k`, supports `count` and wrapped lines)
* **`o`** &rarr; Move Right (replaces `l`)
* **`k`** &rarr; Jump to end of word (replaces `e`)
* **`K`** &rarr; Jump to end of WORD (replaces `E`)
* **`w`** / **`b`** &rarr; Jump to start of word / previous word
* **`0`** / **`$`** &rarr; Start / end of line
* **`gg`** / **`G`** &rarr; Top / bottom of file
* **`5e`** / **`5i`** &rarr; Jump down / up 5 lines (supports numeric count prefixes)

### Insert Mode & Line Creation
* **`u`** &rarr; Insert mode before cursor (replaces `i`, aligns with physical QWERTY `I` position)
* **`U`** &rarr; Insert at beginning of line (replaces `I`)
* **`l`** &rarr; Open line below (replaces `o`)
* **`L`** &rarr; Open line above (replaces `O`)
* **`a`** / **`A`** &rarr; Append after cursor / end of line
* **`h`** / **`H`** &rarr; Insert mode / start of line aliases
* **`Esc`** or **`Ctrl + c`** &rarr; Exit insert mode

### Undo, Redo & Editing
* **`z`** &rarr; Undo (identical physical position on both Colemak-DH & QWERTY, left pinky)
* **`Z`** &rarr; Redo (or `Ctrl + r`)
* **`cuw`** &rarr; Change inner word (`u` functions as inner text object)
* **`duw`** / **`yuw`** / **`vuw`** &rarr; Delete / yank / select inner word
* **`cc`** / **`C`** &rarr; Change line / change to end of line
* **`.`** &rarr; Repeat last edit
* **`<leader>w`** &rarr; Save file immediately (auto-save also saves after 1s delay)
* **`<leader>uv`** &rarr; Toggle auto-save on/off (`:ASToggle`)

### Search Navigation
* **`/pattern`** &rarr; Search forward
* **`?pattern`** &rarr; Search backward
* **`j`** &rarr; Repeat search in same direction (replaces `n`)
* **`J`** &rarr; Repeat search in reverse direction (replaces `N`)
* **`<leader>ch`** &rarr; Clear search highlight

### Window Management & Split Screen
* **`<leader>ws`** &rarr; Split window horizontally
* **`<leader>wv`** &rarr; Split window vertically
* **`<leader>wd`** (or `:close`) &rarr; Close active split
* **`<C-w>o`** (or `:only`) &rarr; Close all other splits (keep only active window)
* **`<C-w>n`** &rarr; Switch to window on the **LEFT**
* **`<C-w>e`** &rarr; Switch to window **BELOW**
* **`<C-w>i`** &rarr; Switch to window **ABOVE**
* **`<C-w>o`** &rarr; Switch to window on the **RIGHT**
* **`<C-w>=`** &rarr; Equalize window sizes

### Neo-tree File Explorer
* **`<leader>e`** &rarr; Toggle file explorer
* **`e`** / **`i`** &rarr; Navigate Down / Up
* **`n`** &rarr; Collapse folder or jump to parent
* **`o`** (or `<CR>`) &rarr; Open file or expand folder
* **`a`** &rarr; Create new file (append `/` for directory)
* **`d`** / **`r`** &rarr; Delete / Rename
* **`c`** / **`x`** / **`p`** &rarr; Copy / Cut / Paste
* **`H`** &rarr; Toggle hidden files (dotfiles)
* **`I`** &rarr; Show file details (shifted from `i`)
* **`E`** &rarr; Toggle auto-expand width (shifted from `e`)
* **`O`** &rarr; Order by menu (`On` name, `Os` size)
* **`q`** &rarr; Close explorer

### LSP & Code Navigation
* **`gh`** or **`<leader>k`** &rarr; Hover documentation (replaces displaced `K`)
* **`gd`** &rarr; Go to definition
* **`gD`** &rarr; Go to declaration
* **`gi`** &rarr; Go to implementation
* **`gr`** &rarr; Find references
* **`<leader>ca`** &rarr; Code actions (quick-fix)
* **`<leader>cr`** (or `<leader>rn`) &rarr; Rename symbol project-wide
* **`<leader>cf`** (or `<leader>f`) &rarr; Format document (`clang-format`)
* **`<leader>c<Tab>`** &rarr; Switch between source and header (`.cpp` &harr; `.h`)
* **`[d`** / **`]d`** &rarr; Jump to previous / next diagnostic error

---

## 4. Configuration Architecture (`%LOCALAPPDATA%\nvim`)

The setup is built upon **LazyVim** with modular overrides:

```text
C:\Users\bit\AppData\Local\nvim\
├── init.lua                   # Entry loader (require("config.lazy"))
├── lazyvim.json               # LazyVim extras state
├── lua/
│   ├── config/
│   │   ├── lazy.lua           # Plugin manager bootstrap & extras imports
│   │   ├── keymaps.lua        # Colemak-DH bindings, C compile runner, splits
│   │   ├── options.lua        # Editor preferences (4-space tabs, scrolloff)
│   │   └── autocmds.lua       # Kernel C indent detection
│   └── plugins/
│       ├── c_cpp.lua          # Clangd LSP, --query-driver, DAP keys, Mason
│       ├── blink.lua          # Lua fuzzy implementation (WDAC fix)
│       ├── treesitter.lua     # Disable auto-install to avoid lock conflicts
│       ├── neotree.lua        # Colemak-DH explorer navigation
│       └── autosave.lua       # Auto-save after 1s delay (modern editor behavior)
```

### Key Configuration Breakdown:

1. **`lua/plugins/c_cpp.lua`**:
   * Configures `clangd` with `--query-driver=**` so it automatically queries MinGW for `<iostream>` and standard library headers.
   * Maps LSP hover to **`gh`** and **`<leader>k`** so Colemak **`K`** (End of WORD) remains untouched.
   * Configures `codelldb` and `clang-format` through Mason.

2. **`lua/plugins/blink.lua`**:
   * Sets `fuzzy = { implementation = "lua" }`.
   * Avoids loading unsigned Rust `.dll` files in AppData that trigger Windows Defender Application Control (WDAC).

3. **`lua/plugins/treesitter.lua`**:
   * Sets `ensure_installed = {}` and `auto_install = false`.
   * Prevents `tree-sitter-cli` from running background compilation that leaves stale lock files. Uses Neovim's built-in parsers (`c.dll`, `lua.dll`, `vim.dll`).

4. **`lua/plugins/neotree.lua`**:
   * Sets `mappings = { ["e"] = "none", ["i"] = "none" }` so Colemak Down/Up motions pass through seamlessly.
   * Binds `n` to `smart_left` (collapses open folder, or jumps to parent directory if on a file/collapsed folder).
   * Binds `o` to `smart_right` (expands folder / focuses first child, or opens file).

5. **`lua/plugins/autosave.lua`**:
   * Uses `okuuva/auto-save.nvim` with a 1000ms (`debounce_delay`) timer (matching modern editors like VS Code's `afterDelay`).
   * Automatically saves after 1 second of inactivity across both Normal and Insert modes (`TextChanged`, `TextChangedI`, `InsertLeave`).
   * Saves immediately upon switching buffers or losing window focus (`BufLeave`, `FocusLost`).
   * Excludes special UI buffers (terminal, neo-tree, Telescope, git commits, unmodifiable files).
   * Toggle on/off anytime with **`<leader>uv`** or **`:ASToggle`**.

---

## 5. Daily Development Loop

1. **Open your project file in Neovim:**
   ```powershell
   nvim C:\Users\bit\Documents\programing\cpp\first.cpp
   ```
2. **Navigate & edit** using home-row **`neio`** movement and **`u`** to enter insert mode.
3. **Write C++ code:** Autocomplete for `std::cout`, `std::vector`, and standard headers appears automatically via `clangd`.
4. **Format:** Press **`<leader>cf`** to format code with `clang-format`.
5. **Compile & Run:** Press **`<leader>cc`** to compile with `clang++` and run the executable directly in an integrated terminal split.
6. **Manage Splits:** Press **`:only`** (or `<C-w>o` / `<leader>wd`) to close splits.
7. **Quick Save & Quit:** Press **`<leader>w`** to save, **`<leader>q`** to quit.
