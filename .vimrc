" #################### GENERAL
filetype plugin indent on   " == filetype on (filetype dection, for syntax and options) + filetype plugin on (loads ftplugin.vim) + filetype indent on (loads indent.vim)
" http://vi.stackexchange.com/a/10125

" Install Vim-Plug if not yet already installed
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/dense-analysis/ale
Plug 'dense-analysis/ale'     " Syntax checker / linter
Plug 'Raimondi/delimitMate'   " Automatic closing of quotes, parenthesis, brackets, etc
Plug 'sjl/badwolf'            " Color theme
Plug 'tpope/vim-surround'     " surround.vim: quoting/parenthesizing made simple

call plug#end()

set laststatus=2 " show the satus line all the time"
set scrolloff=3 " always show at least 3 lines above and below the cursor
set statusline+=%F\ line:%l\ col:%c

set statusline+=%#warningmsg#
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction
set statusline+=%{LinterStatus()}
set statusline+=%*

set backupdir=~/.vim/backup,~/.tmp,~/tmp,/var/tmp,/tmp
set directory=~/.vim/swap,~/.tmp,~/tmp,/var/tmp,/tmp

" toggle invisible characters
set list
set listchars=tab:→\ ,eol:¬,trail:⋅,extends:❯,precedes:❮

set encoding=utf-8 " The encoding displayed
set fileencoding=utf-8 " The encoding written to file
set ffs=unix,dos,mac " Use Unix as the standard file type

" MARKDOWN
autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,markdown} set filetype=markdown

" SPACES and TABS
set tabstop=4                    " number of visual spaces per TAB
set softtabstop=4                " number of spaces in tab when editing
set expandtab                    " tabs are spaces
set backspace=2 " allow backspace on everything in insert mode, http://stackoverflow.com/questions/10727392/vim-not-allowing-backspace
set shiftwidth=4                 " control how many columns text is indented with the reindent operations (<< and >>) and automatic C-style indentation
set shiftround              " round indent to a multiple of 'shiftwidth'"
" set textwidth=100 " maximum width of text that is being inserted (longer lines may be broken after white space)

set diffopt+=vertical

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
set showcmd                      " show command in bottom bar
set cursorline " highlight current line
set autoindent                   " Apply the indentation of the current line to the next
"set smartindent "Smart indent based on syntax/style of code, SHOULD NOT BE USED with 'filetype indent on': http://vim.wikia.com/wiki/Indenting_source_code
set lazyredraw                   " redraw only when we need to.
set showmatch                    " highlight matching [{()}]
set mat=2                        " how many tenths of a second to blink when matching brackets
set laststatus=2                 " Always show the status line

" SEARCHING
set ignorecase                   " ignore case when searching
set smartcase                    " Override the 'ignorecase' option if the search pattern contains upper case characters
set incsearch                    " search as characters are entered
set hlsearch                     " highlight searches (undo :noh)
set magic                        " for regular expressions turn magic on

" When follows is commented because the theme takes care of it
set background=dark
colorscheme badwolf              " awesome colorscheme
syntax enable                    " enable syntax highlighting; 'syntax on' would overrule my settings

" OTHER
set autoread                     " set to auto read when a file is changed from the outside
set history=9999                 " sets how many lines of history VIM has to remember

" typing consl + space will print console.log()
imap consl console.log()<Esc>==f(a

autocmd BufNewFile *.html call Generate_Html()

function! Generate_Html()
    call append(0,  '<!DOCTYPE html>')
    call append(1,  '<html lang="en">')
    call append(2,  '    <head>')
    call append(3,  '        <meta charset="utf-8">')
    call append(4,  '        <meta name="viewport" content="width=device-width, initial-scale=1">')
    call append(5,  '        <link rel="stylesheet" href="main.css" type="text/css" />')
    call append(6,  '        <script src=""></script>')
    call append(7,  '        <title></title>')
    call append(8,  '    </head>')
    call append(9,  '    <body>')
    call append(10, '    </body>')
    call append(11, '</html>')
endfunction

set ttyfast " improves performance
set synmaxcol=200 " Lines longer than 200 won't get syntax highlighting after that longer; improves performance

let mapleader = ','
" search for word under the cursor
nnoremap <leader>/ "fyiw :/<c-r>f<cr>"

" Disable Arrow keys in Escape mode
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>

" ############# LINES #############
set number          " show absolute line numbers
set relativenumber  " also show relative line numbers

" Display absolute line numbers in insert mode, and relative in normal and
" visual modes
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set relativenumber


""" When opening a file : - Reopen at last position
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

autocmd filetype crontab setlocal nobackup nowritebackup

set mouse=a
" Open all cmd args in new tabs
" Needs to be HERE otherwise other tabs will not have all the .vimrc loaded
execute ":silent tab all"
