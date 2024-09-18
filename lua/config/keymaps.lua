-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- lua/plugins/keymaps.lua
local live_grep = require("plugins.live-grep")
local wk = require("which-key")

vim.keymap.set("n", "<leader>s.", require("telescope").extensions.live_grep_args.live_grep_args, { noremap = true })
