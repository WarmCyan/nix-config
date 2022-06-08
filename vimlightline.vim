let g:lightline = { 
    \ 'colorscheme': 'powerline', 
    \ 'active': {
    \       'left': [ [ 'mode', 'paste' ],
    \                 [ 'readonly', 'filename', 'modified', 'lsp_info', 'lsp_hints', 'lsp_errors', 'lsp_warnings', 'lsp_ok', 'lsp_status' ] ],
    \       'right': [ [ 'lineinfo' ],
    \                  [ 'percent', 'linecount' ],
    \                  [ 'fileformat', 'fileencoding', 'filetype' ] ]
    \   },
    \   'component': {
    \       'linecount': '%L'
    \   }
    \ }

call lightline#lsp#register()
