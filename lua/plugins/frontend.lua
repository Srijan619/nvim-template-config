-- NOTE: Make sure typescript , typescript-language-server and prettier is installed either locally in the workspace or globally
return {

  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require("null-ls")

      -- Setup null-ls
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier,
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
