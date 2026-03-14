" TODO: could still use some cleanup

if has('mouse')
    set mouse=a
    set mousehide " hide mouse when typing text
endif

" misc???
" syntax on
filetype plugin indent on

" colorscheme monokai " too much purple, hard to read
if has('termguicolors')
    set termguicolors

    " https://vi.stackexchange.com/questions/13458/make-vim-show-all-the-colors
    " correct RGB escape codes for vim inside tmux
    if !has('nvim') && $TERM ==# 'screen-256color'
      let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
      let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
endif

" colorscheme! 
set background=dark
let g:everforest_background='hard'
let g:everforest_enable_italic=0
let g:everforest_current_word='bold'
let g:everforest_inlay_hints_background='dimmed'
colorscheme everforest

" ==============================================================================
" SETTINGS
" ==============================================================================

" look
set number " line numbers!
set scrolloff=4 " keep 4 visible lines around cursorline when near top or bottom
set cursorline " bghighlight of current line
set title " window title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
"set laststatus=2 " always show status line
"set statusline=%t\ %m%*\ %y%h%r%w\ %<%F\ %*\ %=\ Lines:\ %L\ \ \ Col:\ %c\ \ \ [%n]
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

autocmd FileType ruby setlocal tabstop=2 
autocmd FileType ruby setlocal shiftwidth=2 
autocmd FileType ruby setlocal softtabstop=2 

autocmd FileType yaml setlocal tabstop=2 
autocmd FileType yaml setlocal shiftwidth=2 
autocmd FileType yaml setlocal softtabstop=2 

autocmd FileType sh setlocal tabstop=2 
autocmd FileType sh setlocal shiftwidth=2 
autocmd FileType sh setlocal softtabstop=2 

autocmd FileType nix setlocal tabstop=2 
autocmd FileType nix setlocal shiftwidth=2 
autocmd FileType nix setlocal softtabstop=2 

autocmd FileType javascript setlocal foldmethod=indent
autocmd FileType javascript setlocal tabstop=2 
autocmd FileType javascript setlocal shiftwidth=2 
autocmd FileType javascript setlocal softtabstop=2 

autocmd FileType vue setlocal foldmethod=indent
autocmd FileType vue setlocal tabstop=2 
autocmd FileType vue setlocal shiftwidth=2 
autocmd FileType vue setlocal softtabstop=2

autocmd FileType make setlocal noexpandtab
autocmd FileType make setlocal softtabstop=0

" folding
set foldenable
set foldmethod=syntax
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo " commands that unfold a section
set foldcolumn=1

" text editing behavior
set encoding=utf-8
set autoindent " smart indenting based on filetype
set textwidth=80 " cols before auto wrap text
" see :h fo-table
set formatoptions=l " long lines won't be broken up if entering insert mode and already past textwidth
"set formatoptions=t " auto-wrap lines based on textwidth
set formatoptions+=c " auto-wrap comments using text width and auto insert comment leader
set formatoptions+=j " be all smart and when joing a comment line, take out the extra comment leader
set formatoptions+=q " allow formatting of comments with 'gq'
set formatoptions+=r " automatically insert comment  leader after hitting enter in insert mode
set backspace=indent,eol,start whichwrap+=<,>,[,] " backspace and cursor keys wrap to previous/next line

" modeline is the set of vim settings that can be included in the first few or
" last few lines of a file
set modeline
set modelines=5


" directories/file handling
set autoread
set backup
set undofile
set swapfile
set backupdir=~/tmp/bak
set undodir=~/tmp/undo
set directory=~/tmp/swap

" if directories don't already exist, make them
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif


" ==============================================================================
" KEY BINDINGS
" ==============================================================================

" -- <Core Bindings> -- 
"  if using some other program's vim mode, if it allows at least minimal
"  customization, use these bindings to get the most important shortcuts
"  working. 
" ------------------------------------------------------------------------------
" ESC to leave insert mode is terrible! 'jk' is much nicer
inoremap jk <SPACE><BS><ESC>
inoremap JK <SPACE><BS><ESC>
inoremap Jk <SPACE><BS><ESC>

" make ',' find next character, like ';' normally does
nnoremap , ;

" press ';' in normal mode instead of ':', it's too common to use shift all the time!
nnoremap ; :
vnoremap ; :

" make yank work the same as the other keys
nnoremap Y y$

" more sane usages of H and L
nmap H ^
nnoremap L $

" convert word before cursor (or on cursor) to upper case (uses z mark)
inoremap <C-u> <esc>mzgUiw`za
nnoremap <C-u> mzgUiw`z

" leader shortcuts!
nnoremap <LEADER><SPACE> :nohlsearch<CR>

" ------------------------------------------------------------------------------
"  -- </Core Bindings> --

" better window navigation
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" CTRL-C for copy
vnoremap <C-C> "+y

" CTRL-V for paste
nnoremap <C-V> "+gP
cnoremap <C-V> <C-R>+

" normally CTRL-V is the column select, but change it to ctrl-b
nnoremap <c-b> <c-v>

" shortcuts to move back and forth in buffers
nnoremap <F2> :bprevious<CR>
nnoremap <F3> :bnext<CR>

" fix broken CTRL-A increment number shortcut to CTRL-I
nnoremap <C-I> <C-A>

" tab control
" I'm moving these instead to buffer controls because of the
" bufferline plugin
" nnoremap <tab>h :tabprev<cr>
" nnoremap <tab>l :tabnext<cr>
" nnoremap <tab><enter> :tabnew<cr>
" nnoremap <tab>x :tabclose<cr>
 
nnoremap <tab>h :bprevious<cr>
nnoremap <tab>l :bnext<cr>
nnoremap <tab>x :bdelete<cr>

" split line (on next space)
nnoremap S f<space>s<cr><esc>==

" todo-cycling with my custom td-state tool
nmap <s-t> V:'<,'>!td-state "`cat`"<cr>W

" make terminal also use jk for escape
tnoremap jk <C-\><C-n>

" terminal split creation shortcuts
noremap <C-t>h <C-w>v:terminal<cr>a
noremap <C-t>j <C-w>s<C-w>j:terminal<cr>a
noremap <C-t>k <C-w>s:terminal<cr>a
noremap <C-t>l <C-w>v<C-w>l:terminal<cr>a

" the tree-sitter pluggin introduces a :EditQuery command which makes it so that
" :E no longer means :Explore. To re-allow this, essentially redefining an :E
" command, see https://stackoverflow.com/questions/14367440/map-e-to-explore-in-command-mode 
command! -nargs=* -bar -bang -count=0 -complete=dir E Explore <args>


" ==============================================================================
" ABBREVIATIONS
" ==============================================================================

abbreviate note NOTE:
abbreviate todo TODO:
abbreviate bug BUG:
abbreviate idea IDEA:


" ==============================================================================
" SPECIAL SYNTAX HIGHLIGHTING
" ==============================================================================

" highlight todo.txt syntax
autocmd BufRead,BufNewFile * syntax match TODO_todo "\vTODO\:" containedin=ALL
autocmd BufRead,BufNewFile * syntax match TODO_strt "\vSTRT\:" containedin=ALL
autocmd BufRead,BufNewFile * syntax match TODO_wait "\vWAIT\:" containedin=ALL
autocmd BufRead,BufNewFile * syntax match TODO_done "\vDONE\:" containedin=ALL
autocmd BufRead,BufNewFile * syntax match TODO_canc "\vCANC\:" containedin=ALL

autocmd BufRead,BufNewFile * highlight TODO_todo ctermfg=magenta cterm=bold guifg=#af87ff gui=bold
autocmd BufRead,BufNewFile * highlight TODO_strt ctermfg=cyan cterm=bold guifg=#51ceff gui=bold
autocmd BufRead,BufNewFile * highlight TODO_wait ctermfg=yellow cterm=bold guifg=#fff26d gui=bold
autocmd BufRead,BufNewFile * highlight TODO_done ctermfg=green cterm=bold guifg=#b1e05f gui=bold
autocmd BufRead,BufNewFile * highlight TODO_canc ctermfg=red cterm=bold guifg=#f6669d gui=bold

highlight link Todo TODO_todo 
highlight link pythonTodo TODO_todo 
highlight link javaScriptCommentTodo TODO_todo

" link in custom treesitter captures
if has('nvim')
    highlight link @comment.todo TODO_todo
    highlight link @TODO_todo TODO_todo
    highlight link @TODO_strt TODO_strt
    highlight link @TODO_wait TODO_wait
    highlight link @TODO_done TODO_done
    highlight link @TODO_canc TODO_canc
    highlight link @NOTES_bug NOTES_bug
    highlight link @NOTES_fixd NOTES_fixd
    highlight link @NOTES_idea NOTES_idea
    highlight link @NOTES_note NOTES_note
    highlight link @comment.note NOTES_note
endif


" highlight bug/fixes/ideas
autocmd BufRead,BufNewFile * syntax match NOTES_bug "\vBUG\:" containedin=ALL
autocmd BufRead,BufNewFile * syntax match NOTES_fixd "\vFIXD\:" containedin=ALL
autocmd BufRead,BufNewFile * syntax match NOTES_idea "\vIDEA\:" containedin=ALL
autocmd BufRead,BufNewFile * syntax keyword NOTES_note NOTE containedin=ALL

autocmd BufRead,BufNewFile * highlight NOTES_bug ctermfg=red cterm=bold guifg=#f6669d gui=bold
autocmd BufRead,BufNewFile * highlight NOTES_fixd ctermfg=green cterm=bold guifg=#b1e05f gui=bold
autocmd BufRead,BufNewFile * highlight NOTES_idea ctermfg=blue cterm=bold guifg=#00afff gui=bold
autocmd BufRead,BufNewFile * highlight NOTES_note ctermfg=DarkCyan cterm=underline guifg=#43a8d0 gui=underline

" highlight URLs
autocmd BufRead,BufNewFile * syntax match URL "\vhttps?\:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}([-a-zA-Z0-9()!@:%_\+.~#?&\/\/=]*)" containedin=ALL
autocmd BufRead,BufNewFile * highlight URL ctermfg=magenta cterm=underline guifg=#af87ff gui=bold


" stop bold facing comments 
autocmd BufRead,BufNewFile * highlight Comment cterm=None gui=None



