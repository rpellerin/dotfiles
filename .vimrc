" use "+y to copy to system clipboard and "*y to copy to middle mouse button clipboard

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin('~/some/path/here')
"
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'https://github.com/shime/vim-livedown.git' " Live preview of markdown
Plugin 'https://github.com/Valloric/YouCompleteMe' " Auto completion
Plugin 'https://github.com/scrooloose/syntastic' " Syntax checker
Plugin 'Raimondi/delimitMate' " automatic closing of quotes, parenthesis, brackets, etc
Plugin 'sjl/badwolf' " Color theme
Plugin 'ctrlpvim/ctrlp.vim' " Fuzzy file, buffer, mru, tag, etc finder

" Syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"################ CUSTOM ##################

set encoding=utf-8 " The encoding displayed
set fileencoding=utf-8 " The encoding written to file
set ffs=unix,dos,mac " Use Unix as the standard file type

" SHOW A VERTICAL RULER
highlight Overlength ctermbg=red ctermfg=white guibg=#592929
" match Overlength /\%101v.\+/

" COLOR
colorscheme badwolf              " awesome colorscheme
syntax enable                    " enable syntax processin, don't use 'syntaxt on' as it overrules my settings

" MARKDOWN
autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,markdown} set filetype=markdown

" SPACES and TABS
set tabstop=4                    " number of visual spaces per TAB
set softtabstop=4                " number of spaces in tab when editing
set expandtab                    " tabs are spaces
set backspace=2                  " allow backspace on everything in insert mode
set smarttab                     " be smart when using tabs
set shiftwidth=4                 " control how many columns text is indented with the reindent operations (<< and >>) and automatic C-style indentation
" set textwidth=100
set ai "Auto indent
set si "Smart indent

function! <SID>StripTrailingWhitespaces()
    let _s=@/
    let l=line(".")
    let c=col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction

let blacklist = ['markdown']
autocmd BufWritePre * if index(blacklist, &ft) < 0 | :call <SID>StripTrailingWhitespaces()

" UI
set number                       " show line numbers
set showcmd                      " show command in bottom bar
set cursorline                   " highlight current line
set autoindent                   " copy indent on new line
filetype indent on               " load filetype-specific indent files
set wildmenu                     " visual autocomplete for command menu
set lazyredraw                   " redraw only when we need to.
set showmatch                    " highlight matching [{()}]
set mat=2                        " how many tenths of a second to blink when matching brackets
set ignorecase                   " case insensitive
set ruler                        " Line/char number, percentage in the bottom right of the screen
set laststatus=2                 " Always show the status line

" SEARCHING
set ignorecase                   " ignore case when searching
set smartcase                    " when searching try to be smart about cases"
set incsearch                    " search as characters are entered
set hlsearch                     " highlight
set magic                        " for regular expressions turn magic on

" OTHER
set autoread                     " set to auto read when a file is changed from the outside
set history=50000                " sets how many lines of history VIM has to remember
"
