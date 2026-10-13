# Neovim & Colemak-DH Environment for C/C++ Development

A high-performance Neovim environment built on **LazyVim**, tailored specifically for the **Colemak-DH** (`neio`) keyboard layout, modern **C++23** competitive programming and low-level development, seamless **Windows** integration, and full browser parity with **Vimium**.

---

## Highlights

* ⌨️ **Ergonomic Colemak-DH Layout:** Home-row navigation using `neio` (Left, Down, Up, Right), `u` for insert mode (matching physical QWERTY 'i'), `z` / `Z` for undo / redo, and `<C-w> + n/e/i/o` for window management.
* ⚡ **C++23 Toolchain & Fast Build Workflow:** Integrated with WinLibs GCC MinGW-w64 (`g++ -std=c++23 -O2`) and `cf-runner` via `<F6>` / `<leader>cc` in split terminal.
* 🧠 **Smart Autocomplete (`blink.cmp`):**
  * **Dynamic Recency (MRU):** Remembers recently accepted completions and prioritizes them at the top.
  * **Standard Library Intelligence:** Automatically prepends and inserts `std::` for C/C++ functions and types (e.g. `std::string`, `std::abs`).
  * **Contextual Templates:** Starter snippets (`cp`, `cp1`) are boosted at the top of new files (lines 1–3) and hidden later in the file.
* 📐 **Strict 4-Space Indentation:** Harmonized across Neovim (`cindent`, `shiftround`, `tabstop=4`, `shiftwidth=4`), `clangd`, and root `.clang-format`.
* 💾 **Silent Non-Intrusive Auto-Save:** Automatically persists files in the background without interrupting typing in insert mode or causing cursor spasms.
* 🌐 **Vimium Browser Parity:** Custom key mappings for the Vimium browser extension mirroring Neovim navigation (`neio`), search, and tab switching.
* 📖 **Interactive Cheat Sheet:** Self-contained, responsive Tokyo Night cheat sheet (`Vim Cheat Sheet.html`) with real-time command search.

---

## Directory Structure

```text
├── nvim/
│   ├── init.lua                  # Neovim entrypoint
│   ├── lazyvim.json              # LazyVim configuration & installed extras
│   ├── lazy-lock.json            # Pinned plugin lockfile
│   ├── .clang-format             # LLVM 4-space code formatting rules
│   ├── SETUP.md                  # Comprehensive environment reference
│   ├── lua/
│   │   ├── config/
│   │   │   ├── autocmds.lua      # C/C++ buffer options (4 spaces, cindent)
│   │   │   ├── keymaps.lua       # Colemak-DH mappings & compilation shortcuts
│   │   │   ├── lazy.lua          # Lazy.nvim package manager bootstrap
│   │   │   └── options.lua       # Global editor options
│   │   └── plugins/
│   │       ├── autosave.lua      # Non-intrusive auto-save configuration
│   │       ├── blink.lua         # Blink.cmp with dynamic recency & std:: prefixing
│   │       ├── c_cpp.lua         # Clangd LSP, clang-format, CodeLLDB DAP
│   │       ├── neotree.lua       # File explorer with Colemak navigation
│   │       └── treesitter.lua    # Syntax highlighting configuration
│   └── snippets/
│       └── cpp.json              # Competitive programming starter templates (cp, cp1)
├── vimium/
│   ├── vimium-options.txt        # Copy-pasteable Vimium custom key mappings
│   └── README.md                 # Vimium installation & link hint guide
├── .clang-format                 # Root clang-format configuration
├── .gitignore                    # Ignored build binaries and swap files
├── LICENSE                       # Project license
├── README.md                     # This file
└── Vim Cheat Sheet.html          # Interactive Tokyo Night cheat sheet
```

---

## Colemak-DH Keybindings Reference

### 1. Cursor Movement (`neio` cluster)
| Key | Action | Replaces |
| :--- | :--- | :--- |
| `n` | Move Left | `h` |
| `e` | Move Down | `j` |
| `i` | Move Up | `k` |
| `o` | Move Right | `l` |
| `k` / `K` | Jump to end of word / WORD | `e` / `E` |
| `w` / `b` | Jump forward / backward to start of word | `w` / `b` |
| `0` / `$` | Start of line / end of line | `0` / `$` |
| `gg` / `G` | First line / last line of document | `gg` / `G` |

### 2. Insert Mode & Line Creation
| Key | Action | Note |
| :--- | :--- | :--- |
| `u` | Insert mode | Physical QWERTY `i` key position |
| `U` | Insert at beginning of line | Replaces `I` |
| `l` | Open line below and insert | Replaces `o` |
| `L` | Open line above and insert | Replaces `O` |
| `a` / `A` | Append after cursor / end of line | Standard |
| `h` / `H` | Insert mode alias | Ergonomic alternate |

### 3. Editing, Undo & Search
| Key | Action | Note |
| :--- | :--- | :--- |
| `z` | Undo | Same physical key on Colemak & QWERTY |
| `Z` or `<C-r>` | Redo | Displaced from Ctrl-r |
| `j` | Next search match | Replaces `n` |
| `J` | Previous search match | Replaces `N` |
| `<leader>ch` | Clear search highlights | Custom shortcut |
| `cuw` / `duw` | Change / delete inner word | `u` acts as inner text object |

### 4. Window Splits & Switching
| Key | Action |
| :--- | :--- |
| `<C-w> n` | Focus window on LEFT |
| `<C-w> e` | Focus window BELOW |
| `<C-w> i` | Focus window ABOVE |
| `<C-w> o` | Focus window on RIGHT |
| `<C-w> w` | Cycle to next window |
| `<C-w> p` | Jump to previous window (quick toggle) |
| `<leader>wv` / `<leader>ws` | Split window vertically / horizontally |
| `<leader>wd` | Close active split |

### 5. Tabs & Buffers
| Key | Action |
| :--- | :--- |
| `<leader>bn` or `]b` | Next open buffer / tab |
| `<leader>bp` or `[b` | Previous open buffer / tab |
| `<leader>bd` | Close buffer without closing split layout |
| `<leader>bb` | Toggle last active buffer |
| `gt` / `gT` | Next / previous tab page |

---

## C/C++ Build, Run & Debugging

* **`<F6>`** or **`<leader>cc`**: Compile C/C++ file with C++23 flags and execute with `cf-runner` in split terminal.
* **`<leader>m`**: Run `:make` using project Makefile.
* **`<leader>cf`** or **`<leader>f`**: Format code with `clang-format` (4 spaces).
* **`gh`** or **`<leader>k`**: LSP hover documentation.
* **`<leader>cr`**: Rename symbol project-wide.
* **`<leader>db`**: Toggle breakpoint (CodeLLDB).
* **`<leader>dc`**: Start / continue debugger.
* **`<leader>di`** / **`<leader>dO`** / **`<leader>do`**: Step into / over / out.

---

## Vimium Browser Parity

To bring the same Colemak-DH muscle memory into Chrome/Brave/Edge:
1. Install the [Vimium extension](https://github.com/philc/vimium).
2. Copy the key mappings from [`vimium/vimium-options.txt`](./vimium/vimium-options.txt).
3. Paste into **Vimium Options $\to$ Custom key mappings** and save (`Ctrl+Enter`).
4. Set **Characters used for link hints** to `arstdhneio` (Colemak home keys).

---

## License

This configuration is open source and available under the [MIT License](LICENSE).
