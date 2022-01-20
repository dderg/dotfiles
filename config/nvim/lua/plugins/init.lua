local fn = vim.fn

local Plug = fn['plug#']

local plugLoad = fn["functions#PlugLoad"]

plugLoad()


vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'RRethy/nvim-base16'

Plug 'kyazdani42/nvim-web-devicons'
Plug 'kyazdani42/nvim-tree.lua'

Plug 'nvim-telescope/telescope.nvim'
Plug('nvim-telescope/telescope-fzf-native.nvim', {['do'] = 'make'})
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

Plug 'easymotion/vim-easymotion' -- movement plugin

Plug 'alexghergh/nvim-tmux-navigation'

vim.call('plug#end')

require("plugins.nvimtree")
require("plugins.fzf")
