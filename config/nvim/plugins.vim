" check whether vim-plug is installed and install it if necessary
let plugpath = expand('<sfile>:p:h'). '/autoload/plug.vim'
if !filereadable(plugpath)
    if executable('curl')
        let plugurl = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
        call system('curl -fLo ' . shellescape(plugpath) . ' --create-dirs ' . plugurl)
        if v:shell_error
            echom "Error downloading vim-plug. Please install it manually.\n"
            exit
        endif
    else
        echom "vim-plug not installed. Please install it manually or install curl.\n"
        exit
    endif
endif

call plug#begin('~/.config/nvim/plugged')

" colorschemes
" Plug 'joshdick/onedark.vim'
Plug 'chriskempson/base16-vim'
" Plug 'sjl/badwolf'
" Plug 'altercation/vim-colors-solarized'
" Plug 'w0ng/vim-hybrid'
" Plug 'mhartington/oceanic-next'
" Plug 'morhetz/gruvbox'

" utilities
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] } | Plug 'Xuyuanp/nerdtree-git-plugin' " file drawer
Plug '/usr/local/opt/fzf' | Plug 'junegunn/fzf.vim' " fuzzy file finder and so much more
Plug 'rking/ag.vim' " search inside files using ag, same as ag utility, but use :Ag
Plug 'Raimondi/delimitMate' " automatic closing of quotes, parenthesis, brackets, etc.
Plug 'tpope/vim-commentary' " comment stuff out
Plug 'tpope/vim-ragtag' " endings for html, xml, etc. - enhances surround
Plug 'tpope/vim-surround' " mappings to easily delete, change and add such surroundings in pairs, such as quotes, parens, etc.
Plug 'benmills/vimux' " tmux integration for vim
Plug 'vim-airline/vim-airline' " fancy statusline
Plug 'vim-airline/vim-airline-themes' " themes for vim-airline
Plug 'w0rp/ale' " asynchronous lint engine
Plug 'tpope/vim-fugitive' " amazing git wrapper for vim
Plug 'airblade/vim-gitgutter' " show git diff
" Plug 'tpope/vim-rhubarb' " hub extension for fugitive
Plug 'tpope/vim-repeat' " enables repeating other supported plugins with the . command
Plug 'editorconfig/editorconfig-vim' " .editorconfig support
" Plug 'MarcWeber/vim-addon-mw-utils' " interpret a file by function and cache file automatically
" Plug 'tomtom/tlib_vim' " utility functions for vim
" Plug 'sotte/presenting.vim', { 'for': 'markdown' } " a simple tool for presenting slides in vim based on text files
" Plug 'ervandew/supertab' " Perform all your vim insert mode completions with Tab
" Plug 'AndrewRadev/splitjoin.vim' " single/multi line code handler: gS - split one line into multiple, gJ - combine multiple lines into one
Plug 'vim-scripts/matchit.zip' " extended % matching
Plug 'tpope/vim-sleuth' " detect indent style (tabs vs. spaces)
" Plug 'sickill/vim-pasta' " context-aware pasting
Plug 'easymotion/vim-easymotion' " movement plugin
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py --tern-completer --gocode-completer' } " code completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " completion
Plug 'zchee/deoplete-go', { 'do': 'make'} " gocode
Plug 'embear/vim-localvimrc' " local vim config
Plug 'janko-m/vim-test' " testing utility
Plug 'christoomey/vim-tmux-navigator' " C-movement actions in tmux + vim

" html / templates
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript.jsx', 'stylus'] } " emmet support for vim - easily create markdup wth CSS-like syntax
Plug 'gregsexton/MatchTag', { 'for': 'html' } " match tags in html, similar to paren support
Plug 'othree/html5.vim', { 'for': 'html' } " html5 support
Plug 'mustache/vim-mustache-handlebars' " mustach support
Plug 'digitaltoad/vim-pug', { 'for': ['jade', 'pug'] } " pug / jade support

" JavaScript
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx', 'html'] }
Plug 'moll/vim-node', { 'for': 'javascript' } " node support
" Plug 'mxw/vim-jsx', { 'for': ['javascript.jsx', 'javascript'] } " JSX support
" Plug 'ianks/vim-tsx', { 'for': ['typescript.jsx'] } " TSX support
Plug 'mhartington/nvim-typescript', { 'for': ['typescript', 'typescript.tsx'] } " TypeScript completion
" Plug 'HerringtonDarkholme/yats.vim', { 'for': ['typescript'] } " Extended TypeScript support
Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescript.tsx'] } " TypeScript support
Plug 'peitalin/vim-jsx-typescript', { 'for': ['typescript.tsx'] } " Tsx support
Plug 'Quramy/tsuquyomi', { 'for': ['typescript', 'typescript.tsx'] } " Typescript go to definition
" Plug 'Quramy/tsuquyomi-vue', { 'for': ['vue'] } " Typescript vue support
Plug 'posva/vim-vue', { 'for': ['vue'] } " vue support
" Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'], 'do': 'npm install' }
" Plug 'jason0x43/vim-tss', { 'for': ['typescript', 'javascript', 'javascript.jsx'], 'do': 'npm install' }

" styles
Plug 'wavded/vim-stylus', { 'for': ['stylus', 'markdown'] } " markdown support
" Plug 'groenewege/vim-less', { 'for': 'less' } " less support
Plug 'ap/vim-css-color', { 'for': ['css','stylus','scss'] } " set the background of hex color values to the color
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' } " CSS3 syntax support
" Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' } " sass scss syntax support

" markdown
Plug 'itspriddle/vim-marked', { 'for': 'markdown', 'on': 'MarkedOpen' } " Open markdown files in Marked.app - mapped to <leader>m
Plug 'tpope/vim-markdown', { 'for': 'markdown' } " markdown support

" language-specific plugins
Plug 'elzr/vim-json', { 'for': 'json' } " JSON support
Plug 'Shougo/vimproc.vim', { 'do': 'make' } " interactive command execution in vim
Plug 'fatih/vim-go', { 'for': 'go' } " go support
Plug 'timcharper/textile.vim', { 'for': 'textile' } " textile support

call plug#end()

