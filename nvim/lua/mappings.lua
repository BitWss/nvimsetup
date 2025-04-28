require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Build and run single-file C++ programs
vim.keymap.set("n", "<leader>rr", 
  ":!C:/msys64/ucrt64/bin/g++.exe -Wall % -o %:r.exe && %:r.exe<CR>", 
  { desc = "Build/Run C++ file", noremap = true })

-- Build all the cpp files in the directory
vim.keymap.set("n", "<leader>ca", ":!g++ -std=c++23 -Wall *.cpp -o main<CR>", { desc = "Build all C++ files" })

vim.keymap.set("n", "<leader>cb", ":!g++ -std=c++23 -Wall % -o %:r.exe<CR>", { desc = "Build C++23 file" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
