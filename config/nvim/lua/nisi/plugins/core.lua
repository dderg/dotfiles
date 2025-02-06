return {

  "tpope/vim-unimpaired",
  "tpope/vim-surround",
  "tpope/vim-ragtag",
  "tpope/vim-abolish",
  "tpope/vim-repeat",
  "AndrewRadev/splitjoin.vim",
  "tpope/vim-sleuth",
  "easymotion/vim-easymotion",
  "editorconfig/editorconfig-vim", -- TODO is this still required?
  "alexghergh/nvim-tmux-navigation",
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      -- see below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/personal",
        },
        {
          name = "work",
          path = "~/vaults/work",
        },
      },

      -- see below for full list of options 👇
    },
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      plugins = {
        tmux = { enabled = true },
        wezterm = {
          enabled = true,
          font = "+2",
        },
      },
    },
  },
  {
    "andymass/vim-matchup",
    cond = not vim.g.vscode,
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  {
    "itchyny/vim-qfedit",
    cond = not vim.g.vscode,
    event = "VeryLazy",
  },
  {
    "windwp/nvim-autopairs",
    cond = not vim.g.vscode,
    config = true,
  },
  {
    "nvim-pack/nvim-spectre",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cond = not vim.g.vscode,
    config = true,
    keys = {
      { "<leader>sr", "<cmd>lua require('spectre').open()<cr>", desc = "Open spectre" },
      { "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", desc = "Open spectre" },
      { "<leader>sp", "<cmd>lua require('spectre').open_file_search()<cr>", desc = "Open spectre" },
      { "<leader>ss", "<cmd>lua require('spectre').open()<cr>", desc = "Open spectre" },
    },
  },
  {
    "nat-418/boole.nvim",
    opts = {
      mappings = {
        increment = "<C-a>",
        decrement = "<C-x>",
      },
      -- User defined loops
      additions = {
        -- { "Foo", "Bar" },
        -- { "tic", "tac", "toe" },
      },
      allow_caps_additions = {
        { "enable", "disable" },
        -- enable → disable
        -- Enable → Disable
        -- ENABLE → DISABLE
      },
    },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    cond = not vim.g.vscode,
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    "Bekaboo/dropbar.nvim",
    -- optional, but required for fuzzy finder support
    cond = not vim.g.vscode,
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
  },
}
