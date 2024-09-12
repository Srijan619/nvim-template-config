return {
  "nvim-treesitter/nvim-treesitter",
  run = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "javascript", "typescript", "html", "css" },
      highlight = {
        enable = true,
      },
      -- Enable Treesitter-based folding
      fold = {
        enable = true,
      },
    })

    -- Enable folding based on Treesitter
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
    vim.wo.foldlevel = 99 -- Set the default fold level here (adjust as needed)
  end,
}
