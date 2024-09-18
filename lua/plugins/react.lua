-- NOTE: Make sure typescript , typescript-language-server and prettier is installed either locally in the workspace or globally
return {
  -- Syntax highlighting for JavaScript and TypeScript
  --{ "pangloss/vim-javascript" },
  --{ "MaxMEllon/vim-jsx-pretty" },

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
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require("null-ls")

      -- Setup null-ls
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "html", "css" },
          }),
        },
        on_attach = function(client, bufnr)
          -- Add auto-format on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr, -- Only apply to the current buffer
            callback = function()
              -- Check if the client supports document formatting
              if client.server_capabilities.documentFormattingProvider then
                -- Safely call formatting
                pcall(function()
                  vim.lsp.buf.format()
                end)
              end
            end,
          })

          -- Set keymap for manual formatting
          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_buf_set_keymap(
              bufnr,
              "n",
              "<Leader>cf",
              "<Cmd>lua vim.lsp.buf.format({ async = true })<CR>",
              { noremap = true, silent = true }
            )
          end
        end,
      })
    end,
  },
}
