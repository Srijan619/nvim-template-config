-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- lua/plugins/keymaps.lua

local telescope = require("telescope")
local actions = require("telescope.actions")
local lga_actions = require("telescope-live-grep-args.actions")
local live_grep_args = telescope.extensions.live_grep_args.live_grep_args

vim.keymap.set("n", "<leader>s.", function()
  live_grep_args({
    default_text = "", -- Start empty for the search term
    attach_mappings = function(_, map)
      -- Bind Ctrl + c for *.coffee files
      map("i", "<C-c>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.coffee" })(prompt_bufnr)
      end)
      -- Bind Ctrl + f for *.feature files
      map("i", "<C-f>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.feature" })(prompt_bufnr)
      end)
      -- Bind Ctrl + j for *.java files
      map("i", "<C-j>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.java" })(prompt_bufnr)
      end)
      -- Bind Ctrl + r for *.ruby files
      map("i", "<C-r>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.ruby" })(prompt_bufnr)
      end)
      -- Bind Ctrl + t for *.ts and *.tsx files
      map("i", "<C-t>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.ts *.tsx" })(prompt_bufnr)
      end)
      -- Bind Ctrl + k for *.js and *.jsx files
      map("i", "<C-k>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.js *.jsx" })(prompt_bufnr)
      end)
      -- Bind Ctrl + v for *.vue files
      map("i", "<C-v>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.vue" })(prompt_bufnr)
      end)
      -- Bind Ctrl + y for *.yaml files
      map("i", "<C-y>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.yaml" })(prompt_bufnr)
      end)
      -- Bind Ctrl + d for *.docker files
      map("i", "<C-d>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.docker" })(prompt_bufnr)
      end)
      -- Bind Ctrl + h for *.html files
      map("i", "<C-h>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.html" })(prompt_bufnr)
      end)
      -- Bind Ctrl + s for *.css, *.scss, and *.sass files
      map("i", "<C-s>", function(prompt_bufnr)
        lga_actions.quote_prompt({ postfix = " -g *.css *.scss *.sass" })(prompt_bufnr)
      end)
      return true
    end,
  })
end, { desc = "Live grep args prompt" })
