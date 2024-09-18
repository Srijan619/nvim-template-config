return {
  "nvim-telescope/telescope-live-grep-args.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    -- Load the telescope live_grep_args extension
    require("telescope").load_extension("live_grep_args")
  end,
}
