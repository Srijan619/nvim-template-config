-- NOTE: Make sure typescript , typescript-language-server and prettier is installed either locally in the workspace or globally
return {
  -- Syntax highlighting for JavaScript and TypeScript
  --{ "pangloss/vim-javascript" },
  --{ "MaxMEllon/vim-jsx-pretty" },

  -- LSP configuration for React (TypeScript and JavaScript)
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Define on_attach function
      local on_attach = function(client, bufnr)
        local buf_set_keymap = vim.api.nvim_buf_set_keymap
        local buf_set_option = vim.api.nvim_buf_set_option
        local opts = { noremap = true, silent = true }

        -- Enable completion triggered by <c-x><c-o>
        buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        -- Key mappings
        buf_set_keymap(bufnr, "n", "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>ds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>ws", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
        buf_set_keymap(bufnr, "n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
        buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
        buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
      end

      lspconfig.tsserver.setup({
        on_attach = on_attach,
        capabilities = cmp_nvim_lsp.default_capabilities(),
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
