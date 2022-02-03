-- init.lua
-- Neovim-specific configuration

require("globals")
local opt = vim.opt
local cmd = vim.cmd
local g = vim.g
local o = vim.o
local fn = vim.fn
local env = vim.env
local utils = require("utils")
local termcodes = utils.termcodes
local nmap = utils.nmap
local vmap = utils.vmap
local imap = utils.imap
local xmap = utils.xmap
local omap = utils.omap
local nnoremap = utils.nnoremap
local inoremap = utils.inoremap
local vnoremap = utils.vnoremap
local colors = require("theme").colors

opt.backup = false -- don't use backup files
opt.writebackup = false -- don't backup the file while editing
opt.swapfile = false -- don't create swap files for new buffers
opt.updatecount = 0 -- don't write swap files after some number of updates

opt.backupdir = {
  "~/.vim-tmp",
  "~/.tmp",
  "~/tmp",
  "/var/tmp",
  "/tmp"
}

opt.directory = {
  "~/.vim-tmp",
  "~/.tmp",
  "~/tmp",
  "/var/tmp",
  "/tmp"
}

opt.history = 1000 -- store the last 1000 commands entered
opt.textwidth = 120 -- after configured number of characters, wrap line

opt.inccommand = "nosplit" -- show the results of substition as they're happening
-- but don't open a split

opt.backspace = {"indent", "eol,start"} -- make backspace behave in a sane manner
opt.clipboard = {"unnamed", "unnamedplus"} -- use the system clipboard
opt.mouse = "a" -- set mouse mode to all modes

-- Appearance
---------------------------------------------------------
o.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.autoindent = true
opt.smartindent = true
opt.cursorline = true

opt.expandtab = true -- insert tabs rather than spaces for <Tab>
opt.smarttab = true -- tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
opt.tabstop = 4 -- the visible width of tabs
opt.shiftwidth = 4 -- number of spaces to use for indent and unindent
opt.shiftround = true -- round indent to a multiple of 'shiftwidth'

cmd [[set foldmethod=expr]] -- treesitter folding
cmd [[set foldexpr=nvim_treesitter#foldexpr()]]
opt.foldlevelstart = 99
opt.foldnestmax = 10 -- deepest fold is 10 levels
opt.foldenable = false -- don't fold by default
opt.foldlevel = 1

cmd [[ca Ag Ag!]]

-- toggle invisible characters
opt.list = true
opt.listchars = {
  tab = "→ ",
  eol = "¬",
  trail = "⋅",
  extends = "❯",
  precedes = "❮"
}

opt.hlsearch = false
opt.ttyfast = true -- faster redrawing
opt.laststatus = 2 -- show the satus line all the time
opt.so = 7 -- set 7 lines to the cursors - when moving vertical
opt.wildmenu = true -- enhanced command line completion
opt.hidden = true -- current buffer can be put into background
opt.showcmd = true -- show incomplete commands
opt.showmode = true -- don't show which mode disabled for PowerLine
opt.wildmode = {"list", "longest"} -- complete files like a shell
opt.scrolloff = 5 -- lines of text around cursor
opt.shell = env.SHELL
opt.cmdheight = 1 -- command bar height
opt.title = true -- set terminal title
opt.showmatch = true -- show matching braces
opt.mat = 2 -- how many tenths of a second to blink
opt.updatetime = 300
opt.signcolumn = "yes"
opt.shortmess = "atToOFc" -- prompt message options


opt.wrap = false

g.mapleader = ","

imap("eu", "<Esc>")
nmap("<leader>w", ":w<cr>")

require("plugins")
-- require("nvim-tmux-navigation")

cmd('colorscheme base16-oceanicnext')

cmd [[nnoremap <silent> <C-h> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateLeft()<cr>]]
cmd [[nnoremap <silent> <C-j> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateDown()<cr>]]
cmd [[nnoremap <silent> <C-k> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateUp()<cr>]]
cmd [[nnoremap <silent> <C-l> :lua require'nvim-tmux-navigation'.NvimTmuxNavigateRight()<cr>]]

cmd [[ nnoremap <leader>s :mksession!<cr> ]]

nmap("/", "<Plug>(easymotion-sn)")
omap("/", "<Plug>(easymotion-tn)")

nmap("n", "<Plug>(easymotion-next)")
nmap("N", "<Plug>(easymotion-prev)")


-- Remap keys for applying codeAction to the current line.
nmap("<leader>ac", "<Plug>(coc-codeaction)")
-- Apply AutoFix to problem on the current line.
nmap("<leader>qf", "<Plug>(coc-fix-current)")
-- GoTo code navigation.
nmap("gd", "<Plug>(coc-definition)")
nmap("gy", "<Plug>(coc-type-definition)")
nmap("gi", "<Plug>(coc-implementation)")
nmap("gr", "<Plug>(coc-references)")

cmd [[nnoremap <silent> <leader>gt :call functions#show_documentation()<CR>]]

g.EasyMotion_smartcase = 1
g.gitgutter_realtime = 1
g.gitgutter_eager = 1

