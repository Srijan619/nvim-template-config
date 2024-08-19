local function setup()
  local augroup = vim.api.nvim_create_augroup("coffeescript", { clear = true })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.coffee",
    group = augroup,
    callback = function()
      vim.defer_fn(function()
        -- Syntax highlighting for CoffeeScript
        vim.api.nvim_command("syntax match CoffeeComment '#.*$'")
        vim.api.nvim_command(
          "syntax match CoffeeKeyword '\\<\\(if\\|else\\|for\\|in\\|switch\\|of\\|when\\|while\\|return\\|class\\|extends\\|super\\|this\\|constructor\\)\\>'"
        )
        vim.api.nvim_command("syntax match CoffeeFunction '\\<\\(function\\|->\\|=>\\)\\>'")
        vim.api.nvim_command("syntax match CoffeeString /'[^']*'\\|\"[^\"]*\"/")

        vim.api.nvim_command("syntax match CoffeeNumber '\\<[0-9]\\+\\(\\.[0-9]\\+\\)?\\>'")
        vim.api.nvim_command("syntax match CoffeeBoolean '\\<true\\|false\\>'")
        vim.api.nvim_command("syntax match CoffeeVariable '@\\w\\+'")

        -- Syntax highlighting for log levels (e.g., log.e, log.w, log.i)
        vim.api.nvim_command("syntax match CoffeeLogError 'log\\.e'")
        vim.api.nvim_command("syntax match CoffeeLogWarning 'log\\.w'")
        vim.api.nvim_command("syntax match CoffeeLogInfo 'log\\.i'")

        -- Match any function call, dynamically capturing function names
        vim.cmd("syntax match CoffeeFunctionParams /\\v\\((\\s*[^()]*)\\)/")
        -- Define colors for the syntax groups using extracted values
        vim.api.nvim_set_hl(0, "CoffeeComment", { fg = "#6a9955", ctermfg = 113 }) -- Color from JSON
        vim.api.nvim_set_hl(0, "CoffeeKeyword", { fg = "#c586c0", ctermfg = 164 }) -- Color from JSON
        vim.api.nvim_set_hl(0, "CoffeeFunction", { fg = "#dcdcaa", ctermfg = 179 }) -- Adjusted color
        vim.api.nvim_set_hl(0, "CoffeeString", { fg = "#ce9178", ctermfg = 215 }) -- Adjusted color
        vim.api.nvim_set_hl(0, "CoffeeNumber", { fg = "#b5cea8", ctermfg = 155 }) -- Adjusted color
        vim.api.nvim_set_hl(0, "CoffeeBoolean", { fg = "#569cd6", ctermfg = 81 }) -- Adjusted color
        vim.api.nvim_set_hl(0, "CoffeeVariable", { fg = "#9cdcfe", ctermfg = 81 }) -- Color from JSON

        vim.api.nvim_set_hl(0, "CoffeeFunctionParams", { fg = "#86897A", ctermfg = 237 }) -- Dynamic function calls

        -- Add specific highlighting for arrow functions
        vim.api.nvim_set_hl(0, "CoffeeArrowFunction", { fg = "#4682B4", ctermfg = 33 }) -- Example color for arrows

        -- Highlight arrows separately
        vim.api.nvim_command("syntax match CoffeeArrowFunction '->\\|=>'")

        -- Define colors for log levels
        vim.api.nvim_set_hl(0, "CoffeeLogError", { fg = "#FF6347", ctermfg = 9 }) -- Tomato (Red) for log.e
        vim.api.nvim_set_hl(0, "CoffeeLogWarning", { fg = "#FFA500", ctermfg = 214 }) -- Orange for log.w
        vim.api.nvim_set_hl(0, "CoffeeLogInfo", { fg = "#4682B4", ctermfg = 33 }) -- Steel Blue for log.i

        -- Add folding settings for CoffeeScript
        vim.cmd([[syntax region coffeeFold start=/\vdefine/ end=/->/ fold]])
        vim.api.nvim_command("setlocal foldmethod=syntax")
        -- Close all folds automatically after the file is loaded
        vim.cmd("normal! zM")
      end, 50)
    end,
  })
end

return { setup = setup }
