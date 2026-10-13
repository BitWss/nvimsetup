# Vimium Browser Extension - Colemak-DH Configuration

This directory contains the custom key mapping configuration for the [Vimium browser extension](https://github.com/philc/vimium) designed to maintain full muscle memory parity with our Neovim Colemak-DH setup.

---

## 1. Quick Setup

1. Open **Vimium Options** in your browser (click the Vimium extension icon $\to$ **Options**, or press `?` on any page and click **Options**).
2. Scroll to the **Custom key mappings** text box.
3. Paste the contents of [`vimium-options.txt`](./vimium-options.txt) into the box.
4. Scroll to the bottom and click **Save Changes** (or press `Ctrl+Enter`).
5. Reload your open browser tabs.

---

## 2. Link Hints Optimization (Colemak Home Row)

Under **Advanced Options $\to$ Characters used for link hints** in the Vimium settings page, replace the default characters with:

```text
arstdhneio
```

This ensures yellow link hint badges only generate letters from your Colemak-DH home keys, allowing you to click links across the web without reaching across the keyboard.

---

## 3. Keybindings Summary

| Action | Vimium Key | Neovim Equivalent |
| :--- | :--- | :--- |
| **Move Left** | `n` | `n` |
| **Move Down** | `e` | `e` |
| **Move Up** | `i` | `i` |
| **Move Right** | `o` | `o` |
| **Scroll Half Page Down** | `<C-d>` or `d` | `<C-d>` |
| **Scroll Half Page Up** | `<C-u>` or `u` | `<C-u>` |
| **Scroll to Top** | `gg` | `gg` |
| **Scroll to Bottom** | `G` | `G` |
| **Find Next Match** | `j` | `j` |
| **Find Prev Match** | `J` | `J` |
| **Next Tab** | `gt` or `]b` | `gt` / `<leader>bn` / `]b` |
| **Prev Tab** | `gT` or `[b` | `gT` / `<leader>bp` / `[b` |
| **Close Tab** | `x` | `<leader>bd` / `:bd` |
| **Restore Closed Tab** | `X` | `:undo` |
| **Open URL / Search** | `l` | `<leader><space>` |
| **Open URL in New Tab** | `L` | `:vsp` |
| **Search Open Tabs** | `T` | `<leader>,` / `<leader>fb` |
| **Link Hints** | `f` / `F` | Flash jump |
| **History Back** | `H` | `<C-o>` |
| **Pass Keys to Page** | `I` *(Shift-I)* | `u` (Insert Mode) |
