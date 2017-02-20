" https://github.com/KtorZ/dotfiles/blob/master/vimrc
" https://github.com/sd65/MiniVim/blob/master/vimrc

set nocompatible              " do not act as vi, required
filetype off                  " will be re-enabled at the end of the file anyway
" http://vi.stackexchange.com/a/10125

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
Plugin 'https://github.com/tpope/vim-dispatch' " Compile asynchronously and show output in splitted pane

set laststatus=2
set statusline+=%F\ line:%l\ col:%c

" Syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
" Not sure those next two commands are necessary
let g:syntastic_cpp_compiler = 'g++'
let g:syntastic_cpp_compiler_options = '-std=c++11 -stdlib=libc++'

" http://usevim.com/2016/03/07/linting/
let g:syntastic_error_symbol = '❌'
let g:syntastic_style_error_symbol = '⁉️'
let g:syntastic_warning_symbol = '⚠️'
let g:syntastic_style_warning_symbol = '💩'

highlight link SyntasticErrorSign SignColumn
highlight link SyntasticWarningSign SignColumn
highlight link SyntasticStyleErrorSign SignColumn
highlight link SyntasticStyleWarningSign SignColumn


" Don't ask if .ycm_extra_conf.py is safe to be loaded
let g:ycm_confirm_extra_conf = 0
let g:ycm_global_ycm_extra_conf = "/home/romain/.ycm_extra_conf.py"
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
"let g:ycm_key_list_select_completion = ['<Enter>']
" For next line, by default TAB and Top/Down
"let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Top>']

call vundle#end()            " required
filetype plugin indent on    " == filetype on (filetype dection, for syntax and options) + filetype plugin on (loads ftplugin.vim) + filetype indent on (loads indent.vim)
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
highlight ExtraWhitespace ctermbg=red guibg=red
" match Overlength /\%101v.\+/

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
set lazyredraw                   " redraw only when we need to.
set showmatch                    " highlight matching [{()}]
set mat=2                        " how many tenths of a second to blink when matching brackets
set ignorecase                   " case insensitive
set laststatus=2                 " Always show the status line

" SEARCHING
set ignorecase                   " ignore case when searching
set smartcase                    " when searching try to be smart about cases"
set incsearch                    " search as characters are entered
set hlsearch                     " highlight
set magic                        " for regular expressions turn magic on

" COLOR
set background=dark
colorscheme badwolf              " awesome colorscheme
syntax enable                    " enable syntax highlighting; 'syntax on' would overrule my settings

" OTHER
set autoread                     " set to auto read when a file is changed from the outside
set history=5000                 " sets how many lines of history VIM has to remember

" typing consl + space will print console.log()
imap consl console.log()<Esc>==f(a

autocmd BufNewFile *.html call Generate_Html()

function Generate_Html()
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


" FINDING FILES:

" Search down into subfolders (from current active directory) and ~/git
" Provides tab-completion for all file-related tasks
" Command is :find something
" * can be used to find matching files
set path+=**,~/git/**

" Display all matching files when we tab complete
set wildmenu


" TAG JUMPING:

" Requires 'ctags' to be installed (via apt-get)
" Creates the 'tags' file
command! MakeTags !ctags -R .
" Now we can use:
" - ^] to jump to tag under cursor
" - g^t for ambiguous tags
" - ^t to jump back up the tag stack


" FILE BROWSING:

" Tweaks for browsing
" Command is :edit <path>
let g:netrw_banner=0        " Disable annoying top banner
let g:netrw_browse_split=3  " open selected file in new tab
let g:netrw_altv=1          " open splits to the right
let g:netrw_liststyle=3     " tree view (allow expanding folders), can be change by pressing i
