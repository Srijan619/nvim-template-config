local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.ui.mini-animate" },

    {
      dir = "~/.config/nvim/lua/plugins/wpro-component-publish",
      name = "wpro-component-publish",
      config = function()
        require("plugins.wpro-component-publish")
      end,
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
    },
    {
      dir = "~/.config/nvim/lua/plugins/coffeescript",
      name = "coffeescript",
      ft = "coffee",
      config = function()
        require("plugins.coffeescript").setup()
      end,
    },
    {
      "f-person/git-blame.nvim",
    },
    {
      "norcalli/nvim-colorizer.lua",
      config = function()
        require("colorizer").setup()
      end,
    },

    -- THEMES
    {
      "projekt0n/github-nvim-theme",
      lazy = false,
      priority = 999,
    },

    {
      "sho-87/kanagawa-paper.nvim",
      lazy = false,
      priority = 1000,
      opts = {},
      config = function()
        -- vim.cmd("colorscheme kanagawa-paper")
      end,
    },
    {
      "rebelot/kanagawa.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd("colorscheme kanagawa")
      end,
    },
    {
      "jiaoshijie/undotree",
      dependencies = "nvim-lua/plenary.nvim",
      config = true,
      keys = {
        { "<S-u>", "<cmd>lua require('undotree').toggle()<CR>", mode = "n" }, -- Normal mode mapping
      },
    },
    ---
    { import = "plugins.fold" },
    { import = "plugins.frontend" },
    { import = "plugins.live-grep" },
    { import = "plugins.lspconfig" },
    -- { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
