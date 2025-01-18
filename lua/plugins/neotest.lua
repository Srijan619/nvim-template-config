return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui", -- UI for nvim-dap
      "theHamsta/nvim-dap-virtual-text", -- Inline variable values
      "nvim-telescope/telescope-dap.nvim", -- Optional: DAP integration with Telescope
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dap.adapters.node2 = {
        type = "executable",
        command = "node",
        args = { "--inspect-brk=0", "${workspaceFolder}/node_modules/playwright/lib/cli.js", "debug" },
      }

      -- JavaScript and TypeScript configurations for Playwright
      dap.configurations.javascript = {
        {
          type = "node2",
          request = "launch",
          name = "Launch Playwright Test",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
          runtimeExecutable = "npx",
          runtimeArgs = { "playwright", "test", "--debug" },
        },
      }

      dap.configurations.typescript = {
        {
          type = "node2",
          request = "launch",
          name = "Launch Playwright Test (TS)",
          program = "${file}",
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = "inspector",
          console = "integratedTerminal",
          runtimeExecutable = "npx",
          runtimeArgs = { "playwright", "test", "--debug" },
          outFiles = { "${workspaceFolder}/dist/**/*.js" },
        },
      }

      -- Configure nvim-dap-ui
      dapui.setup()

      -- Auto-open/close UI when debugging
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keybindings for nvim-dap and nvim-dap-ui
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- Basic debugging keybindings
      map("n", "<F5>", ":lua require'dap'.continue()<CR>", opts) -- Start/Continue debugging
      map("n", "<F10>", ":lua require'dap'.step_over()<CR>", opts) -- Step Over
      map("n", "<F11>", ":lua require'dap'.step_into()<CR>", opts) -- Step Into
      map("n", "<F12>", ":lua require'dap'.step_out()<CR>", opts) -- Step Out

      -- Breakpoints
      map("n", "<leader>db", ":lua require'dap'.toggle_breakpoint()<CR>", opts) -- Toggle Breakpoint
      map("n", "<leader>dB", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts) -- Conditional Breakpoint

      -- DAP UI
      map("n", "<leader>du", ":lua require'dapui'.toggle()<CR>", opts) -- Toggle DAP UI
      map("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>", opts) -- Open REPL
      map("n", "<leader>dl", ":lua require'dap'.run_last()<CR>", opts) -- Run last debug session
    end,
  },
}
