-- neotest.lua
local wk = require("which-key")

-- Ensure the required plugins are set up
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio", -- Required dependency for neotest
    "thenbe/neotest-playwright", -- Playwright adapter for neotest
    "nvim-telescope/telescope.nvim", -- Optional: Telescope integration
  },
  config = function()
    -- Neotest Setup with Playwright Adapter
    require("neotest").setup({
      adapters = {
        require("neotest-playwright").adapter({
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
          },
        }),
      },
      output = {
        open_on_run = true, -- Keep the output window open after running tests
        open_on_error = true, -- Open output on error (useful if there’s a failure)
        focus_on_run = false, -- Disable auto-focus on the output window
        open = "float", -- Show output in a floating window
        close_on_exit = false, -- Prevent closing the floating window immediately after the test finishes
      },
    })

    wk.add({
      { "<leader>t", group = "Test" },
      { "<leader>tT", "<cmd>Neotest stop<cr>", desc = "Stop running tests" },
      { "<leader>ta", "<cmd>Neotest attach<cr>", desc = "Attach to test" },
      { "<leader>tf", "<cmd>Neotest run file<cr>", desc = "Run current file's tests" },
      { "<leader>tl", "<cmd>Neotest run last<cr>", desc = "Run the last test again" },
      { "<leader>tt", "<cmd>Neotest run<cr>", desc = "Run nearest test under cursor" },
      { "<leader>to", "<cmd>Neotest output<cr>", desc = "Show test output" },
      { "<leader>ts", "<cmd>Neotest summary<cr>", desc = "Show summary" },
      { "<leader>tv", "<cmd>Neotest run vimgrep<cr>", desc = "Run tests with vimgrep search" },
    })
  end,
}
