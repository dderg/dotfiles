source ~/.config/nvim/plugins.vim

" Section General {{{

" Abbreviations
abbr funciton function
abbr teh the
abbr tempalte template
abbr fitler filter
abbr cosnt const
ca Ag Ag!

set autoread                " detect when a file is changed

set history=1000            " change history to 1000
set textwidth=120

set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

let g:python_host_prog = '/usr/local/bin/python2'
let g:python3_host_prog = '/usr/local/bin/python3'

" set inccommand=nosplit

" }}}

" Section User Interface {{{

" switch cursor to line when in insert mode, and block when not
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
  \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
  \,sm:block-blinkwait175-blinkoff150-blinkon175

" enable 24 bit color support if supported
if (has('mac') && has("termguicolors"))
    set termguicolors
endif

syntax on
set background=dark
colorscheme base16-oceanicnext " Set the colorscheme

set number                  " show line numbers
set relativenumber          " show relative line numbers

set nowrap                  " now rap

set autoindent              " automatically set indent of new line
set smartindent

" toggle invisible characters
set list
set listchars=tab:→\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
set showbreak=↪

let g:tsuquyomi_disable_quickfix = 1

" highlight conflicts
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" make backspace behave in a sane manner
set backspace=indent,eol,start

" Spell check
" set spell

" Tab control
set expandtab               " insert tabs rather than spaces for <Tab>
set smarttab                " tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=4               " the visible width of tabs
set shiftwidth=4            " number of spaces to use for indent and unindent
set shiftround              " round indent to a multiple of 'shiftwidth'
set completeopt+=longest

" code folding settings
set foldmethod=syntax       " fold based on indent
set foldnestmax=10          " deepest fold is 10 levels
set nofoldenable            " don't fold by default
set foldlevel=1

set clipboard=unnamed

set ttyfast                 " faster redrawing
set diffopt+=vertical
set laststatus=2            " show the satus line all the time
set so=7                    " set 7 lines to the cursors - when moving vertical
set wildmenu                " enhanced command line completion
set hidden                  " current buffer can be put into background
set showcmd                 " show incomplete commands
set noshowmode              " don't show which mode disabled for PowerLine
set wildmode=list:longest   " complete files like a shell
set scrolloff=3             " lines of text around cursor
set shell=$SHELL
set cmdheight=1             " command bar height
set title                   " set terminal title

" Searching
set ignorecase              " case insensitive searching
set smartcase               " case-sensitive if expresson contains a capital letter
set hlsearch!               " highlight search results
set incsearch               " set incremental search, like modern browsers
set nolazyredraw            " don't redraw while executing macros

set magic                   " Set magic on, for regex

set showmatch               " show matching braces
set mat=2                   " how many tenths of a second to blink

set cursorline              " highlight cursor line

" error bells
set noerrorbells
set visualbell
set t_vb=
set tm=500

if has('mouse')
	set mouse=a
	" set ttymouse=xterm2
endif

" }}}

" Section Mappings {{{

" set a map leader for more key combos
let mapleader = ','

" remap esc
inoremap jk <esc>
inoremap eu <esc>

" wipout buffer
nmap <silent> <leader>b :bw<cr>

" shortcut to save
nmap <leader>w :w<cr>

" set paste toggle
" set pastetoggle=<leader>v

" toggle paste mode
" map <leader>v :set paste!<cr>

" edit ~/.config/nvim/init.vim
nnoremap <leader>ev :vsp $MYVIMRC<cr>
" edit zsh convig
nnoremap <leader>ez :vsp ~/.zshrc<cr>

" save current session
nnoremap <leader>s :mksession!<cr>

" clear highlighted search
" noremap <space> :set hlsearch! hlsearch?<cr>

" activate spell-checking alternatives
nmap ;s :set invspell spelllang=en<cr>

" markdown to html
nmap <leader>md :%!markdown --html4tags <cr>

" remove extra whitespace
nmap <leader><space> :%s/\s\+$<cr>
nmap <leader><space><space> :%s/\n\{2,}/\r\r/g<cr>


nmap <leader>l :set list!<cr>

" json format
nmap <leader>jf :call functions#JsonFormat()<cr>
nmap <leader>xf :call functions#XmlFormat()<cr>

" switch between current and last buffer
nmap <leader>. <c-^>

" enable . command in visual mode
vnoremap . :normal .<cr>

" map <silent> <C-h> :wincmd h<cr>
" map <silent> <C-j> :wincmd j<cr>
" map <silent> <C-k> :wincmd k<cr>
" map <silent> <C-l> :wincmd l<cr>
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> :TmuxNavigateDown<cr>
nnoremap <silent> <c-k> :TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :TmuxNavigateRight<cr>

map <leader>wc :wincmd q<cr>

" toggle cursor line
nnoremap <leader>i :set cursorline!<cr>

" scroll the viewport faster
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" moving up and down work as you would expect
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> ^ g^
nnoremap <silent> $ g$

" search for word under the cursor
nnoremap <leader>/ "fyiw :/<c-r>f<cr>

" inoremap <tab> <c-r>=Smart_TabComplete()<CR>

map <leader>r :call RunCustomCommand()<cr>
" map <leader>s :call SetCustomCommand()<cr>
let g:silent_custom_command = 0

" helpers for dealing with other people's code
nmap \t :set ts=4 sts=4 sw=4 noet<cr>
nmap \s :set ts=4 sts=4 sw=4 et<cr>

nnoremap <silent> <leader>u :call functions#HtmlUnEscape()<cr>

" }}}

" Section AutoGroups {{{
" file type specific settings
augroup configgroup
    autocmd!

    " automatically resize panes on resize
    autocmd VimResized * exe 'normal! \<c-w>='
    " save all files on focus lost, ignoring warnings about untitled buffers
    autocmd FocusLost * silent! wa

    " strip trailing whitespaces only for js and ts
    autocmd BufWritePre *.js :call functions#StripTrailingWhitespaces()
    " autocmd BufWritePre *.ts :call functions#StripTrailingWhitespaces()

    autocmd BufNewFile,BufReadPost *.md set filetype=markdown
    let g:markdown_fenced_languages = ['css', 'javascript', 'js=javascript', 'json=javascript', 'stylus', 'html']

    " autocmd! BufEnter * call functions#ApplyLocalSettings(expand('<afile>:p:h'))

    autocmd BufNewFile,BufRead,BufWrite *.md syntax match Comment /\%^---\_.\{-}---$/

    " set filetypes as typescript.jsx
    autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx
    " autocmd BufNewFile,BufRead *.ts setlocal filetype=typescript
augroup END

" }}}

" Section Plugins {{{
let g:localvimrc_ask = 0
let g:localvimrc_sandbox = 0

map <leader>td :TernDef<CR>
map <leader>tt :TernType<CR>
map <leader>tr :TernRename<CR>

map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['eslint', 'tsserver']
\ }

let g:ale_fixers = {
\   'javascript': [
\       'eslint',
\       'prettier',
\   ],
\   'typescript': [
\       'eslint',
\       'prettier',
\   ],
\}

let g:ale_fix_on_save = 1

" let g:ale_completion_enabled = 1;

" Toggle NERDTree
map <silent> <C-\> :NERDTreeToggle<CR>
" expand to the path of the file in the current buffer
nmap <silent> <leader>y :NERDTreeFind<cr>

let NERDTreeShowHidden = 1
" let NERDTreeDirArrowExpandable = '▷'
" let NERDTreeDirArrowCollapsible = '▼'
let g:NERDTreeGlyphReadOnly = "RO"

let g:EasyMotion_smartcase = 1
let g:gitgutter_realtime = 1
let g:gitgutter_eager = 1

" FZF
"""""""""""""""""""""""""""""""""""""
let g:fzf_layout = { 'down': '~25%' }


if isdirectory(".git")
    " if in a git project, use :GFiles
    nmap <silent> <C-p> :GFiles<cr>
else
    " otherwise, use :FZF
    nmap <silent> <C-p> :FZF<cr>
endif

nmap <silent> <leader>r :Buffers<cr>
nmap <silent> <leader>e :FZF<cr>
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

nnoremap <silent> <Leader>C :call fzf#run({
\   'source':
\     map(split(globpath(&rtp, "colors/*.vim"), "\n"),
\         "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')"),
\   'sink':    'colo',
\   'options': '+m',
\   'left':    30
\ })<CR>

command! FZFMru call fzf#run({
\  'source':  v:oldfiles,
\  'sink':    'e',
\  'options': '-m -x +s',
\  'down':    '40%'})

command! -bang -nargs=* Find call fzf#vim#grep(
	\ 'rg --column --line-number --no-heading --follow --color=always '.<q-args>, 1,
	\ <bang>0 ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:50%:hidden', '?'), <bang>0)


" Fugitive Shortcuts
"""""""""""""""""""""""""""""""""""""
nmap <silent> <leader>gs :Gstatus<cr>
nmap <leader>ge :Gedit<cr>
nmap <silent><leader>gr :Gread<cr>
nmap <silent><leader>gb :Gblame<cr>

nmap <leader>m :MarkedOpen!<cr>
nmap <leader>mq :MarkedQuit<cr>
" nmap <leader>* *<c-o>:%s///gn<cr>


let g:user_emmet_settings = {
\   'javascript.jsx': {
\       'extends': 'jsx',
\   },
\ }

" airline options
let g:airline_powerline_fonts=1
let g:airline_detect_spell=0
" let g:airline_left_sep=''
" let g:airline_right_sep=''
let g:airline_theme='dark'
let g:airline#extensions#tabline#enabled = 1 " enable airline tabline
let g:airline#extensions#tabline#tab_min_count = 2 " only show tabline if tabs are being used (more than 1 tab open)
let g:airline#extensions#tabline#show_buffers = 0 " do not show open buffers in tabline
let g:airline#extensions#tabline#show_splits = 0
let g:airline_section_y = ''
let g:airline_section_z = ''

" don't hide quotes in json files
let g:vim_json_syntax_conceal = 0

let g:SuperTabCrMapping = 0

" delimitmMate
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1
let delimitMate_backspace = 1
let delimitMate_balance_matchpairs = 1

" indentLine
" let g:indentLine_color_term = 239
" let g:indentLine_char = "→"
" let g:indentLine_concealcursor=0

" vim-test
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
nmap <silent> <leader>a :TestSuite<CR>
nmap <silent> <leader>l :TestLast<CR>
nmap <silent> <leader>g :TestVisit<CR>

let g:test#javascript#mocha#file_pattern = '\vtests?/.*\.(js|jsx|coffee|ts|tsx)$'

" function MochaTransform(cmd) abort
"   return a:cmd.' --require ts-node/register'
" endfunction

" let g:test#custom_transformations = {'mocha': function('MochaTransform')}
" let g:test#transformation = 'mocha'

let test#strategy = "vimux"

let g:deoplete#enable_at_startup = 1
" }}}

" vim:foldmethod=marker:foldlevel=0
