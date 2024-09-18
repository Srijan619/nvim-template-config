-- Live grep extended with args enabled

local live_grep_in_glob = function(glob_pattern)
  require("telescope.builtin").live_grep({
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--glob=" .. (glob_pattern or ""),
    },
  })
end

live_grep_prompt = function()
  vim.ui.input({ prompt = "Glob: ", completion = "file", default = "**/*." }, live_grep_in_glob)
end

-- Bind to Leader+s
vim.api.nvim_set_keymap("n", "<Leader>s.", "<Cmd>lua live_grep_prompt()<CR>", { noremap = true, silent = true })
