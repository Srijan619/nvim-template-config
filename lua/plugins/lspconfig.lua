return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local wk = require("which-key")

    -- Define on_attach function
    local on_attach = function(client, bufnr)
      local buf_set_option = vim.api.nvim_buf_set_option
      local opts = { noremap = true, silent = true }

      -- Enable completion triggered by <c-x><c-o>
      buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

      -- Define key mappings
      local mappings = {
        g = {
          d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to Definition" },
          r = { "<cmd>lua vim.lsp.buf.references()<CR>", "References" },
          i = { "<cmd>lua vim.lsp.buf.implementation()<CR>", "Implementations" },
        },
        r = {
          n = { "<cmd>lua vim.lsp.buf.rename()<CR>", "Rename" },
          a = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
        },
        f = { "<cmd>lua vim.lsp.buf.formatting()<CR>", "Format" },
        d = {
          s = { "<cmd>lua vim.lsp.buf.document_symbol()<CR>", "Document Symbols" },
          w = { "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", "Workspace Symbols" },
        },
        e = { "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", "Show Diagnostics" },
        ["[d"] = { "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", "Previous Diagnostic" },
        ["]d"] = { "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", "Next Diagnostic" },
      }

      -- Register the key mappings with which-key
      wk.register(mappings, { buffer = bufnr, prefix = "<leader>" })
    end

    lspconfig.tsserver.setup({
      on_attach = on_attach,
      capabilities = cmp_nvim_lsp.default_capabilities(),
    })
  end,
}
