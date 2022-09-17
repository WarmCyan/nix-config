{ inputs, ... }: final: prev:
{
  vimPlugins = prev.vimPlugins // {
    cmp-nvim-lsp-signature-help = prev.vimUtils.buildVimPluginFrom2Nix {
      pname = "cmp-nvim-lsp-signature-help";
      version = "2022-06-08";
      src = prev.fetchFromGitHub {
        owner = "hrsh7th";
        repo = "cmp-nvim-lsp-signature-help";
        rev = "8014f6d120f72fe0a135025c4d41e3fe41fd411b";
        sha256 = "1k61aw9mp012h625jqrf311vnsm2rg27k08lxa4nv8kp6nk7il29";
      };
    };
    # Enable language fencing, e.g. something = /* sh */ ''
    vim-nix = prev.vimPlugins.vim-nix.overrideAttrs
      (_oldAttrs: rec {
        version = "2022-02-20";
        src = prev.fetchFromGitHub {
          owner = "hqurve";
          repo = "vim-nix";
          rev = "26abd9cb976b5f4da6da02ee81449a959027b958";
          sha256 = "sha256-7TDW6Dgy/H7PRrIvTMpmXO5/3K5F1d4p3rLYon6h6OU=";
        };
      });
  }; # // import ../pkgs/vim-plugins { pkgs = prev } # TODO: !!!

  # TODO: could submit this as a pull request to
  # nixpkgs/pkgs/applications/editors/vscode/extensions/default.nix
  vscode-extensions = prev.vscode-extensions // {
    sainnhe.everforest = prev.vscode-utils.extensionFromVscodeMarketplace {
      name = "Everforest";
      publisher = "sainnhe";
      version = "0.2.1";
      sha256 = "sha256-g2zpR+1P99WhUk/AFR/IYoxJwSPohCLbCc35cI2rgL4=";
    };
  };
  
} // import ../pkgs { pkgs = prev; lib = inputs.nixpkgs.lib; }
