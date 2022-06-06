let g:lightline = { 
    \ 'colorscheme': 'powerline', 
    \ 'active': {
        \ 'left': [ [ 'mode', 'paste' ],
                  \ [ 'readonly', 'filename', 'modified'] ],
        \ 'right': [ [ 'lineinfo' ],
                   \ [ 'percent', 'linecount' ],
                   \ [ 'fileformat', 'fileencoding', 'filetype' ] ]'
    \ },
    \ 'component': {
        \ 'linecount': '%L'
    \ },
\ }

