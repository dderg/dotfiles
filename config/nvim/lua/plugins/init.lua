local fn = vim.fn
local cmd = vim.cmd

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
Plug 'tpope/vim-sleuth' -- detect indent style (tabs vs. spaces)

Plug 'alexghergh/nvim-tmux-navigation'

Plug 'Raimondi/delimitMate' -- automatic closing of quotes, parenthesis, brackets, etc.
Plug 'rking/ag.vim' -- search inside files using ag, same as ag utility, but use :Ag
Plug 'tpope/vim-surround' -- mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
Plug 'airblade/vim-gitgutter' -- show git diff

cmd [[Plug 'neoclide/coc.nvim', {'branch': 'release'} ]]
cmd [[Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx', 'html'] }]]
cmd [[Plug 'moll/vim-node', { 'for': 'javascript' } ]]
cmd [[ Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescript.tsx'] } ]]
cmd [[ Plug 'maxmellon/vim-jsx-pretty'   ]]


vim.call('plug#end')

require("plugins.nvimtree")
require("plugins.fzf")
