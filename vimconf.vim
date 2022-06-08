
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



set completeopt=menu,menuone,noselect

lua <<EOF
local cmp = require 'cmp'
local luasnip = require 'luasnip'

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
            select = true,
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
        { name = 'path' },
        { name = 'luasnip' },
        { name = 'nvim_lsp_signature_help' },
    })
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    })
})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())



lspconfig = require 'lspconfig'


-- https://github.com/neovim/nvim-lspconfig
local on_attach = function(client, bufnr)
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', '<C-f>', vim.lsp.buf.formatting, bufopts) -- run autoformat
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts) -- open up a window with info about symbol under cursor
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
end


local servers = { 'pylsp', 'bashls', 'vuels', 'tsserver' }
for _, lsp in pairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities
    }
end

local util = require 'lspconfig/util'
lspconfig.tsserver.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    ---- https://github.com/neovim/nvim-lspconfig/issues/260
    -- root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git") or vim.loop.cwd();
    -- cmd = { "typescript-language-server --stdio --tsserver-path ~/.nix-profile/bin/tsserver" } # can't find it...
})

-- https://github.com/nvim-lualine/lualine.nvim/
-- this has to be at the bottom rather than setting it in the plugin config in nix, otherwise it doesn't auto-start.
-- https://github.com/nvim-lualine/lualine.nvim/issues/697
require('lualine').setup {
    options = {
        theme = 'everforest'
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

EOF
