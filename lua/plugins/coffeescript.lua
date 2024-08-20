local function setup()
  local augroup = vim.api.nvim_create_augroup("coffeescript", { clear = true })

  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.coffee",
    group = augroup,
    callback = function()
      vim.defer_fn(function()
        -- Syntax highlighting for CoffeeScript
        vim.api.nvim_command(
          "syntax match CoffeeKeyword '\\<\\(if\\|else\\|is\\|isnt\\|or\\|and\\|for\\|in\\|switch\\|of\\|when\\|while\\|try\\|catch\\|then\\|fail\\|finally\\|return\\|class\\|extends\\|super\\|this\\|constructor\\)\\>'"
        )
        -- Match function prefixes, but ensure they are not inside strings or comments main functions like _doSomething: () ->
        vim.api.nvim_command("syntax match CoffeeFunctionPrefix /^\\s*\\(\\S\\)\\S*\\s*:\\ze\\s*/") -- ensure functions like pattern doesn't start in the comment block
        vim.api.nvim_command("syntax match CoffeeSubFunctionPrefix /\\v\\.\\zs[^() \\t\\n]*\\ze\\(/") -- Array.push() like
        vim.api.nvim_command("syntax match CoffeeString /'[^']*'\\|\"[^\"]*\"/")

        vim.api.nvim_command("syntax match CoffeeNumber '\\<[0-9]\\+\\(\\.[0-9]\\+\\)?\\>'")
        vim.api.nvim_command("syntax match CoffeeBoolean '\\<true\\|false\\>'")
        vim.api.nvim_command("syntax match CoffeeVariable '@\\w\\+'")

        -- Syntax highlighting for log levels (e.g., log.e, log.w, log.i)
        vim.api.nvim_command("syntax match CoffeeLogError 'log\\.e'")
        vim.api.nvim_command("syntax match CoffeeLogWarning 'log\\.w'")
        vim.api.nvim_command("syntax match CoffeeLogInfo 'log\\.i'")

        -- Match parameters inside parentheses, not including the parentheses themselves
        -- vim.api.nvim_command("syntax match CoffeeParamInside /\\v\\([^()]*\\)/") -- TODO: This is not working..
        -- Apply syntax match to curly brackets (both opening and closing)

        vim.api.nvim_command("syntax match CoffeeCurlyBrackets /[{\\|}]\\v/")
        vim.api.nvim_command("syntax match CoffeeParenthesesBrackets /\\v[()]/")
        vim.api.nvim_command("syntax match CoffeeSquareBrackets /\\v\\[|\\]/")

        -- Interpolation
        vim.api.nvim_command("syntax match CoffeeInterpolation /#{[^}]*}/ containedin=CoffeeString")
        vim.api.nvim_command("syntax match CoffeeInterpolationText /#{\\zs[^}]*\\ze}/ containedin=CoffeeInterpolation")
        -- Define colors for the syntax groups using extracted values
        vim.api.nvim_set_hl(0, "CoffeeKeyword", { fg = "#A390FF", ctermfg = 141 })
        vim.api.nvim_set_hl(0, "CoffeeFunctionPrefix", { fg = "#cdf861", ctermfg = 154 })
        vim.api.nvim_set_hl(0, "CoffeeSubFunctionPrefix", { fg = "#66cdaa", ctermfg = 114 })
        vim.api.nvim_set_hl(0, "CoffeeString", { fg = "#BFD084", ctermfg = 195 })
        vim.api.nvim_set_hl(0, "CoffeeNumber", { fg = "#b5cea8", ctermfg = 155 })
        vim.api.nvim_set_hl(0, "CoffeeBoolean", { fg = "#569cd6", ctermfg = 81 })
        vim.api.nvim_set_hl(0, "CoffeeVariable", { fg = "#9cdcfe", ctermfg = 81 })
        vim.api.nvim_set_hl(0, "CoffeeComment", { fg = "#6f6f6f", ctermfg = 243 })
        --vim.api.nvim_set_hl(0, "CoffeeParamInside", { fg = "#fcb34c", ctermfg = 214 }) -- Dynamic function calls
        vim.api.nvim_set_hl(0, "CoffeeParenthesesBrackets", { fg = "#de7cb0", ctermfg = 204 })
        vim.api.nvim_set_hl(0, "CoffeeCurlyBrackets", { fg = "#de7cb0", ctermfg = 204 })
        vim.api.nvim_set_hl(0, "CoffeeSquareBrackets", { fg = "#de7cb0", ctermfg = 204 })
        vim.api.nvim_set_hl(0, "CoffeeInterpolation", { fg = "#de7cb0", ctermfg = 204 })
        vim.api.nvim_set_hl(0, "CoffeeInterpolationText", { fg = "#A390FF", ctermfg = 141 })

        -- Add specific highlighting for arrow functions
        vim.api.nvim_set_hl(0, "CoffeeArrowFunction", { fg = "#b3e8b4", ctermfg = 151 }) -- Example color for arrows

        -- Highlight arrows separately
        vim.api.nvim_command("syntax match CoffeeArrowFunction '->\\|=>'")

        -- Define colors for log levels
        vim.api.nvim_set_hl(0, "CoffeeLogError", { fg = "#FF6347", ctermfg = 9 }) -- Tomato (Red) for log.e
        vim.api.nvim_set_hl(0, "CoffeeLogWarning", { fg = "#FFA500", ctermfg = 214 }) -- Orange for log.w
        vim.api.nvim_set_hl(0, "CoffeeLogInfo", { fg = "#4682B4", ctermfg = 33 }) -- Steel Blue for log.i

        vim.api.nvim_command("syntax match CoffeeComment '#.*$'") -- Comments at the end such that nothing above will override it

        -- Add folding settings for CoffeeScript
        vim.cmd([[syntax region coffeeDefineImportFold start=/^\s*define/ end=/->/ fold]]) -- auto fold define []
        vim.api.nvim_command("setlocal foldmethod=syntax")
        -- Close all folds automatically after the file is loaded
        vim.cmd("normal! zM")
      end, 50)
    end,
  })
end

return { setup = setup }
