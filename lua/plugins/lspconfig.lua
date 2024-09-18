return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local wk = require("which-key")

    -- Define on_attach function
    local on_attach = function(client, bufnr)
      local buf_set_option = vim.api.nvim_buf_set_option
      -- Enable completion triggered by <c-x><c-o>
      buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

      wk.add({
        { "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "Go to Definition" },
        { "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>", desc = "References" },
        { "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", desc = "Implementations" },
        { "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "Rename" },
        { "<leader>ra", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "Code Action" },
        { "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", desc = "Format" },
        { "<leader>ds", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", desc = "Document Symbols" },
        { "<leader>dw", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", desc = "Workspace Symbols" },
        { "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", desc = "Show Diagnostics" },
        { "<leader>[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", desc = "Previous Diagnostic" },
        { "<leader>]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", desc = "Next Diagnostic" },
      }, { buffer = bufnr })
    end

    lspconfig.tsserver.setup({
      on_attach = on_attach,
      capabilities = cmp_nvim_lsp.default_capabilities(),
    })
  end,
}
