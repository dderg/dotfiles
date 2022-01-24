local fn = vim.fn
local cmd = vim.cmd

local Plug = fn['plug#']

local plugLoad = fn["functions#PlugLoad"]

plugLoad()


vim.call('plug#begin', '~/.config/nvim/plugged')

-- add color highlighting to hex values
cmd [[Plug 'norcalli/nvim-colorizer.lua']]

-- a set of lua helpers that are used by other plugins
cmd [[Plug 'nvim-lua/plenary.nvim']]

Plug 'tpope/vim-commentary' -- comment stuff out

Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

Plug 'nvim-telescope/telescope.nvim'

Plug 'easymotion/vim-easymotion' -- movement plugin
Plug 'tpope/vim-sleuth' -- detect indent style (tabs vs. spaces)

Plug 'alexghergh/nvim-tmux-navigation'

-- automatically complete brackets/parens/quotes
cmd [[Plug 'windwp/nvim-autopairs']]

-- Run prettier and other formatters on save
cmd [[Plug 'mhartington/formatter.nvim']]

Plug 'rking/ag.vim' -- search inside files using ag, same as ag utility, but use :Ag
Plug 'tpope/vim-surround' -- mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
-- Plug 'airblade/vim-gitgutter' -- show git diff
-- Show git information in the gutter
cmd [[Plug 'lewis6991/gitsigns.nvim']]

-- cmd [[Plug 'neoclide/coc.nvim', {'branch': 'release'} ]]
cmd [[Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx', 'html'] }]]
cmd [[Plug 'moll/vim-node', { 'for': 'javascript' } ]]
cmd [[ Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescript.tsx'] } ]]
cmd [[ Plug 'maxmellon/vim-jsx-pretty'   ]]

cmd [[Plug 'ekalinin/Dockerfile.vim']]

-- Helpers to configure the built-in Neovim LSP client
cmd [[Plug 'neovim/nvim-lspconfig']]

-- Helpers to install LSPs and maintain them
cmd [[Plug 'williamboman/nvim-lsp-installer']]

-- neovim completion
cmd [[Plug 'hrsh7th/cmp-nvim-lsp']]
cmd [[Plug 'hrsh7th/cmp-nvim-lua']]
cmd [[Plug 'hrsh7th/cmp-buffer']]
cmd [[Plug 'hrsh7th/cmp-path']]
cmd [[Plug 'hrsh7th/nvim-cmp']]

-- treesitter enables an AST-like understanding of files
cmd [[Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}]]
-- enable more advanced treesitter-aware text objects
cmd [[Plug 'nvim-treesitter/nvim-treesitter-textobjects']]
-- show treesitter nodes
cmd [[Plug 'nvim-treesitter/playground']]

-- show nerd font icons for LSP types in completion menu
cmd [[Plug 'onsails/lspkind-nvim']]

-- base16 syntax themes that are neovim/treesitter-aware
cmd [[Plug 'RRethy/nvim-base16']]

cmd [[ Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } ]]
Plug 'junegunn/fzf.vim'

cmd [[Plug 'folke/trouble.nvim']]

-- Style the tabline without taking over how tabs and buffers work in Neovim
cmd [[Plug 'alvarosevilla95/luatab.nvim']]

-- status line plugin
cmd [[Plug 'feline-nvim/feline.nvim']]

Plug('nvim-telescope/telescope-fzf-native.nvim', {['do'] = 'make'})


vim.call('plug#end')

-- Once the plugins have been loaded, Lua-based plugins need to be required and started up
-- For plugins with their own configuration file, that file is loaded and is responsible for
-- starting them. Otherwise, the plugin itself is required and its `setup` method is called.
require("nvim-autopairs").setup()
require("colorizer").setup()
require("plugins.telescope")
require("plugins.gitsigns")
require("plugins.trouble")
require("plugins.fzf")
require("plugins.lspconfig")
require("plugins.completion")
require("plugins.treesitter")
require("plugins.nvimtree")
require("plugins.formatter")
require("plugins.tabline")
require("plugins.feline")
