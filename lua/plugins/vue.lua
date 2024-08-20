-- Define a function to set fold level based on line count
local function set_fold_based_on_line_count()
  -- Check if the file type is 'vue'
  if vim.bo.filetype ~= "vue" then
    return
  end
  local line_count = vim.api.nvim_buf_line_count(0) -- Get the number of lines in the current buffer
  if line_count > 10 then
    vim.wo.foldlevel = 1 -- Set fold level to 1 if more than 10 lines
  else
    vim.wo.foldlevel = 0 -- No folding if 10 lines or fewer
  end
end

-- Create an autocmd group to apply this setting when a file is read
vim.api.nvim_create_augroup("CustomFoldLevel", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = "CustomFoldLevel",
  pattern = "*",
  callback = set_fold_based_on_line_count,
})

return {
  -- Syntax highlighting for Vue
  { "posva/vim-vue" },

  -- Treesitter for better syntax highlighting and folding
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "vue", "javascript", "typescript", "html", "css" },
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
      vim.wo.foldlevel = 99 -- start unfolded
    end,
  },

  -- LSP configuration for Vue
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("lspconfig").volar.setup({
        -- Volar configuration for Vue 3
        on_attach = on_attach,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    end,
  },

  -- Completion plugin
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  -- Completion sources for LSP
  { "hrsh7th/cmp-nvim-lsp" },

  -- Snippets
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },

  -- Formatter using null-ls
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "vue", "javascript", "typescript", "html", "css" },
          }),
        },
        on_attach = function(client, bufnr)
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_buf_set_keymap(
              bufnr,
              "n",
              "<Leader>cf",
              "<Cmd>lua vim.lsp.buf.format()<CR>",
              { noremap = true, silent = true }
            )
          end
        end,
      })
    end,
  },
}
