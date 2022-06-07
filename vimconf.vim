
if has('mouse')
    set mouse=a
    set mousehide " hide mouse when typing text
endif

" misc???
syntax on
filetype plugin indent on

colorscheme monokai

" ==============================================================================
" SETTINGS
" ==============================================================================

" look
set number " line numbers!
set scrolloff=4 " keep 4 visible lines around cursorline when near top or bottom
set cursorline " bghighlight of current line
set title " window title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
set laststatus=2 " always show status line
set statusline=%t\ %m%*\ %y%h%r%w\ %<%F\ %*\ %=\ Lines:\ %L\ \ \ Col:\ %c\ \ \ [%n]
set noshowmode " mode unnecessary since shown in lightline

" search
set hlsearch " highlight search matches
set incsearch " move highlight as you add charachters to search string
set ignorecase " ignore case in search
set smartcase " ...unless being smart about it!

" tabs
set tabstop=4 " number of columns used for a tab
set shiftwidth=4 " how columns indent operations (<<, >>) use
set softtabstop=4 " how many spaces used when hit tab in insert mode
set expandtab " I've given up the fight on spaces v tabs... :/


" ==============================================================================
" KEY BINDINGS
" ==============================================================================

" ESC to leave insert mode is terrible! 'jk' is much nicer
inoremap jk <SPACE><BS><ESC>
inoremap JK <SPACE><BS><ESC>
inoremap Jk <SPACE><BS><ESC>

" make ',' find next character, like ';' normally does
nnoremap , ;

" press ';' in normal mode instead of ':', it's too common to use shift all the time!
nnoremap ; :
vnoremap ; :

" better window navigation
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l




lua <<EOF
lspconfig = require 'lspconfig'

lspconfig.pylsp.setup{}
EOF
