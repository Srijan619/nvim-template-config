--Floating terminal
return {
  {
    "numToStr/FTerm.nvim",
    config = function()
      require("FTerm").setup({
        border = "double",
        dimensions = {
          height = 1,
          width = 1,
        },
        blend = 6,
      })
    end,
    keys = {
      -- Open a terminal with bbpr command
      {
        "<leader>tb",
        ":lua require('FTerm').run('bbpr')<CR>",
        desc = "Open terminal and run bbpr",
      },
      { "<leader>t", ":lua require('FTerm').toggle()<CR>", desc = "Toggle FTerm terminal" },
      { "<leader>tt", ":lua require('FTerm').open()<CR>", desc = "Open FTerm terminal" },
      { "<leader>tc", ":lua require('FTerm').close()<CR>", desc = "Close FTerm terminal" },
    },
  },
}
