" TODO: could still use some cleanup

if has('mouse')
    set mouse=a
    set mousehide " hide mouse when typing text
endif

" misc???
syntax on
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


" Split line (on next space)
nnoremap S f<space>s<cr><esc>==

" Todo-cycling with my custom td-state tool
nmap <s-t> V:'<,'>!td-state "`cat`"<cr>W

" Make terminal also use jk for escape
tnoremap jk <C-\><C-n>

noremap <C-t>h <C-w>v:terminal<cr>a
noremap <C-t>j <C-w>s<C-w>j:terminal<cr>a
noremap <C-t>k <C-w>s:terminal<cr>a
noremap <C-t>l <C-w>v<C-w>l:terminal<cr>a


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





" ==============================================================================
" LUA PLUGIN SETUP
" ==============================================================================

set completeopt=menu,menuone,noselect
inoremap <c-u> <cmd>lua require("luasnip.extras.select_choice")()<cr>

lua <<EOF
local cmp = require 'cmp'
local luasnip = require 'luasnip'
-- TODO: can't figure out why it won't allow loading multiple paths
require("luasnip.loaders.from_vscode").lazy_load({paths = { "~/.snippets" }})
local types = require("luasnip.util.types")

luasnip.config.setup({
    ext_opts = {
        [types.insertNode] = {
            active = { virt_text = {{"[insert]", "Green"}} }
        },
        [types.choiceNode] = {
            active = { virt_text = {{"[choice]", "Blue"}} }
        },
        [types.snippet] = {
            passive = { virt_text = {{"[snippet active]", "Red"}} }
        }
    }
})

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'buffer' },
        { name = 'treesitter' },
        -- { name = 'path' }, -- https://github.com/hrsh7th/nvim-cmp/issues/874
        { name = 'luasnip' },
        { name = 'nvim_lsp_signature_help' },
    })
})

-- seemed to be breaking command line autocomplete
-- cmp.setup.cmdline(':', {
--     mapping = cmp.mapping.preset.cmdline(),
--     sources = cmp.config.sources({
--         { name = 'path' }
--     })
-- })

local capabilities = require('cmp_nvim_lsp').default_capabilities()



local lspconfig = require 'lspconfig'

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<LEADER>h', vim.diagnostic.setloclist, opts)

vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

-- https://github.com/neovim/nvim-lspconfig
local on_attach = function(client, bufnr)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', '<C-f>', vim.lsp.buf.format, bufopts) -- run autoformat
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts) -- open up a window with info about symbol under cursor
    vim.keymap.set('n', '<C-p>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('i', '<C-p>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<LEADER>r', vim.lsp.buf.rename, bufopts)
end

vim.lsp.set_log_level("debug")

local servers = { 'bashls', 'vuels', 'vimls', 'svelte', 'tsserver' }
for _, lsp in pairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities
    }
end

-- https://neovim.discourse.group/t/pylsp-config-is-not-used/2545
-- https://neovim.discourse.group/t/pylsp-config-is-not-taken-into-account/1846
lspconfig.pylsp.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        pylsp = {
            configurationSources = {"flake8"},
            plugins = {
                pylint = { enabled = false },
                flake8 = { enabled = true },
                -- pycodestyle = { enabled = false },
                -- pyflakes = { enabled = true },
                -- https://github.com/python-lsp/pylsp-mypy/issues/35 conflicts with https://github.com/python-lsp/python-lsp-black ...
                -- black = { enabled = true }, 
                -- pylsp_black = { enabled = true },
                -- pyls_isort = { enabled = true },
                -- pylsp_mypy = { enabled = true, live_mode = true, dmypy = true },
            }
        }
    }
})

local null_ls = require('null-ls')

local util = require 'lspconfig/util'
null_ls.setup({
    sources = {
        -- js
        null_ls.builtins.code_actions.eslint.with({
            only_local = "node_modules/.bin"
        }),
        null_ls.builtins.diagnostics.eslint.with({
            only_local = "node_modules/.bin"
        }),
        null_ls.builtins.formatting.eslint.with({
            only_local = "node_modules/.bin"
        }),

        -- null_ls.builtins.diagnostics.vint

        -- python (these don't seem to work with pylsp, unclear why)
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.isort
    },
    on_attach = on_attach,
    capabilities = capabilities
})


--lspconfig.tsserver.setup({
    --on_attach = on_attach,
    --capabilities = capabilities,
    ------ https://github.com/neovim/nvim-lspconfig/issues/260
    ---- root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git") or vim.loop.cwd();
    --cmd =  { 'typescript-language-server --stdio --log-level 4' }
    --cmd =  { 'typescript-language-server --stdio --tsserver-path /nix/store/06xqyh1191qp1brxm1clhj8nmna2jnak-typescript-4.6.4/bin/tsserver --log-level 4' }
--})


-- https://github.com/nvim-lualine/lualine.nvim/
-- this has to be at the bottom rather than setting it in the plugin config in nix, otherwise it doesn't auto-start.
-- https://github.com/nvim-lualine/lualine.nvim/issues/697
require('lualine').setup {
    options = {
        theme = 'everforest',
        icons_enabled = false
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
        },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
        },
    tabline = {},
    extensions = {}
}

vim.opt.list = true
require("ibl").setup({
    --show_current_context = true,
    --show_current_context_start = true,
    -- use_treesitter = true,
    -- https://github.com/lukas-reineke/indent-blankline.nvim/issues/271
    --context_patterns = {
        --"class", "function", "method", "block", "list_literal", "selector",
        --"^if", "^table", "if_statement", "while", "for",
    --},
})
--require("indent_blankline").setup {
--    show_current_context = true,
--    show_current_context_start = true,
--    -- use_treesitter = true,
--    -- https://github.com/lukas-reineke/indent-blankline.nvim/issues/271
--    --context_patterns = {
--        --"class", "function", "method", "block", "list_literal", "selector",
--        --"^if", "^table", "if_statement", "while", "for",
--    --},
--}

require('nvim_comment').setup()

--require('nvim-web-devicons').setup({
    --default = true
--})

--vim.g.loaded_netrw = 1
--vim.g.loaded_netrwPlugin = 1
-- TODO: does some of this need to go into an on_attach method?

local function tree_on_attach(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
        return { desc="nvim-tree: " .. desc, buffer=bufnr, noremap=true, silent = true, nowait=true }
    end
    
    local function vsplit_preview()
        local node = api.tree.get_node_under_cursor()
        if node.nodes ~= nil then
            -- expand or collapse folder
            api.node.open.edit()
        else
            -- open file as vsplit
            api.node.open.vertical()
        end
        
        -- Finally refocus on tree if it was lost
        api.tree.focus()
    end

    api.config.mappings.default_on_attach(bufnr)

    
    -- TODO: how do I make these shortcuts only apply in the nvimtree window
    vim.keymap.set("n", "L", vsplit_preview, opts("VSplit Preview"))
    --vim.keymap.set("n", "<C-0>", api.tree.close(), opts("VSplit Preview"))
    -- vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
    -- TODO: set c-f to be focus nvim tree if already open
end

require("nvim-tree").setup({
    on_attach=tree_on_attach
})
-- TODO: c-f overwrites autoformat up above
vim.api.nvim_set_keymap("n", "<LEADER>e", ":NvimTreeToggle<cr>", {silent=true, noremap=true})
-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes

require("bufferline").setup({
    options = {
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                text_align = "center",
                separator = true,
            }
        },
        always_show_bufferline = false,
    }
})

require("term-edit").setup({
    prompt_end = '%$ ',
})

require("flatten").setup({})

--require("rsync").setup({})
--require('packer').startup(function(use) 
--    use 'wbthomason/packer.nvim'
--    --use {
--    --    'OscarCreator/rsync.nvim',
--    --    run = 'make',
--    --    requires = {'nvim-lua/plenary.nvim'},
--    --    config = function()
--    --        require("rsync").setup()
--    --    end
--    --}
--end)


require("neotest").setup({
    adapters = {
        require("neotest-python")({
            dap= { justMyCode = false },
        }),
    },
    running={
        concurrent = false -- can run into conflicts between tests
    },
})
vim.api.nvim_set_keymap("n", "<LEADER>t", ":Neotest summary<CR>", {silent=true, noremap=true})

require("dap-python").setup()

-- don't keep swapping out the current buffer if already open in another
local dap = require("dap")
dap.defaults.fallback.switchbuf = 'useopen,uselast'

-- nvim-dap mappings
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F9>', function() require('dap').terminate() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.sidebar(widgets.frames).open()
end)
vim.keymap.set('n', '<Leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.sidebar(widgets.scopes).open()
end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)


require("sibling-swap").setup({
    keymaps = {
        ["<space>l"] = "swap_with_right",
        ["<space>h"] = "swap_with_left",
        ["<space>."] = "swap_with_right_with_opp",
        ["<space>,"] = "swap_with_left_with_opp",
    },
})

require("nvim-surround").setup()

EOF

" otherwise my H binding doesn't work
let g:context_add_mappings = 0

let g:vimwiki_list = [{'path': '~/lazuli/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

let g:vimwiki_global_ext = 0


" https://github.com/liuchengxu/vista.vim/blob/master/doc/vista.txt
let g:vista_default_executive = 'nvim_lsp'
"let g:vista_update_on_text_changed = 1
let g:vista_fzf_preview = ['right:50%']
let g:vista_sidebar_width = 40
let g:vista_echo_cursor_strategy = "floating_win"
let g:vista_cursor_delay = 0
let g:vista_floating_delay = 0
"autocmd FileType vista,vista_kind nnoremap <buffer> <silent> / :<c-u>call vista#finder#fzf#Run()<CR>
nnoremap // :<c-u>Vista finder<CR>
nnoremap <leader>v :Vista<CR>


" https://github.com/wellle/context.vim
let g:context_enabled = 1
