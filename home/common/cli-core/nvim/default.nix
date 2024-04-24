# THE ALL IMPORTANT AND MIGHTY NEOVIM CONFIGURATION STUFFS.
# TODO: at some point possibly move the lsp stuff out to dev?
# unclear if I want to break up nvim configuration into two separate sections,
# but it might make it cleaner here.
# NOTE: that this is what misterio does, though it's just broken up into diff
# files in the same folder, not completely separate directories. 

# TODO: keep vim config separate, and minimal, (and don't set vimAlias) so if
# you want simple/raw editing capability can just use vim instead of neovim.

# TODO: do more space bindings in normal, e.g. recommended for format is
# <space>f, and misterio mapped <space>m to make for example.

# TODO: use relativenumber line numbers ("set number relativenumber")

# TODO: possible plugins:
# vim-illuminate - https://github.com/RRethy/vim-illuminate (highlight other instances of that var/word)
# which-key - https://github.com/folke/which-key.nvim (popup with possible keybindings from what you started typing, useful for remembering posible commands)
# nvim-tree - https://github.com/kyazdani42/nvim-tree.lua (better nerdtree)
# telescope - https://github.com/nvim-telescope/telescope.nvim (consider over vista?)
# trouble - https://github.com/folke/trouble.nvim (nice list of diagnostics errors, better than default)
# medieval - https://github.com/gpanders/vim-medieval (execute code blocks in markdown files)

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

      # TODO: to try next:
      # neotest
      # notebooknavigator.nvim
      # compter.nvim
      # noedim

      # -- Langs --
      vim-nix
      julia-vim

      # -- Utils --
      fzfWrapper # TODO: unclear on differences between this one and fzf-vim
      fzf-vim
      nvim-comment # shortcut to comment lines
      vim-tmux-navigator # vim-side of navigating between tmux/vim panes
      vimwiki # allow using alongside obsidian and still doing link nav
      nvim-tree-lua # file explorer sidebar
      bufferline-nvim # better bufferline that works with both tabs and buffers
      term-edit-nvim # allow editing cmdline text in nvim terminal
      flatten-nvim # opening file in terminal in neovim won't nest
      # rsync-nvim # allow auto syncing from a remote source via rsync
      # packer-nvim # some things are easier to install with the packer nvim package manager. # TODO: just using this to build rsync-nvim
      plenary-nvim # helper functions for many other plugins
      sibling-swap # allow easy swapping of sibling nodes e.g. function args
      nvim-surround # make it easier to change quotes/braces around a thing etc.

      # -- testing and debugging
      unstable.neotest # allow running unit tests within neovim
      neotest-python  # neotest plugin for pytest
      nvim-dap  # debug adapter protocol
      nvim-dap-python # easy config for python dap

      # -- Visual improvements --
      everforest # beautiful colorscheme
      lualine-nvim # better statusline written in lua
      nvim-web-devicons # TODO: unclear if this works w/o font-awesome?
      indent-blankline-nvim # show indent line and current block highlight
      vista-vim # shows a "map" of all the symbols from lsp
      context-vim # similar to the vscode experimental option that keeps the 
                  # current scope line in view

      # -- Autocompletion --
      nvim-cmp
      cmp-buffer
      cmp-spell
      cmp-path

      # -- Treesitter --
      (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars)) # TODO: ??
      cmp-treesitter
      
      # -- LSP --
      nvim-lspconfig # easy configuration setups for a bunch of lsp's
      null-ls-nvim # an lsp server wrapper for any cli utils that don't have dedicated server
      cmp-nvim-lsp
      cmp-nvim-lsp-signature-help # continues to display signature info as you type

      # -- Snippets --
      luasnip
      cmp_luasnip
    ] ++ [
      # pkgs.unstable.vimPlugins.sibling-swap
      # pkgs.unstable.vimPlugins.neotest
    ];

    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      nodePackages.vim-language-server
      nodePackages.vls

      # -- Python language server stuff --
      # python310Packages.python-lsp-server
      # #python310Packages.pylsp-mypy # TODO: unclear if working
      # python310Packages.pyls-isort
      # python310Packages.python-lsp-black
      # python310Packages.flake8

      # -- Python language server stuff --
      # python311Packages.python-lsp-server
      # python311Packages.pyls-isort
      # python311Packages.python-lsp-black
      # python311Packages.flake8
      # python311Packages.debugpy # required for nvim-dap-python to work I think

      # python312Packages.python-lsp-server
      # python312Packages.pyls-isort
      # python312Packages.python-lsp-black
      # python312Packages.flake8
      # python312Packages.debugpy # required for nvim-dap-python to work I think

      (python3.withPackages (ps: with ps; [
        python-lsp-server
        pyls-isort
        python-lsp-black
        flake8
        debugpy
      ]))
    
      universal-ctags # important for vista-vim to work 
      fzf
    ];

    extraPython3Packages = (ps: with ps; [
        jedi
        pynvim
    ]);
  };
}
