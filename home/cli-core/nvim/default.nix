# THE ALL IMPORTANT AND MIGHTY NEOVIM CONFIGURATION STUFFS.

{ pkgs, ... }:

let
    inherit (builtins) readFile;
in
{
    programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;

        extraConfig = readFile ./vim-conf.vim;

        plugins = with pkgs.vimPlugins; [

            # -- Langs --
            vim-nix

            # -- Utils --
            fzfWrapper # TODO: unclear on differences between this one and fzf-vim
            fzf-vim
            nvim-comment # shortcut to comment lines
            vim-tmux-navigator # vim-side of navigating between tmux/vim panes

            # -- Visual improvements --
            everforest # beautiful colorscheme
            lualine-nvim # better statusline written in lua
            nvim-web-devicons # TODO: unclear if this works w/o font-awesome?
            indent-blankline-nvim # show indent line and current block highlight
            vista-vim # shows a "map" of all the symbols from lsp

            # -- Autocompletion --
            nvim-cmp
            cmp-buffer
            cmp-spell
            cmp-treesitter
            cmp-path

            # -- LSP --
            nvim-lspconfig # easy configuration setups for a bunch of lsp's
            null-ls-nvim # an lsp server wrapper for any cli utils that don't have dedicated server
            (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars)) # TODO: ??
            cmp-nvim-lsp
            cmp-nvim-lsp-signature-help # continues to display signature info as you type

            # -- Snippets --
            luasnip
            cmp_luasnip
        ];

        extraPackages = with pkgs; [
            nodePackages.bash-language-server
            nodePackages.vim-language-server

            # -- Python language server stuff --
            python39Packages.python-lsp-server
            python39Packages.pylsp-mypy # TODO: unclear if working
            python39Packages.pyls-isort
            python39Packages.python-lsp-black
            python39Packages.flake8

            universal-ctags # important for vista-vim to work 
            fzf
        ];

        extraPython3Packages = (ps: with ps; [
            jedi
            pynvim
        ]);
    };
}
