# TODO: we need probably an exclusively unstable set of overlays and stable set?
{ inputs, ... }: final: prev:
{
  vimPlugins = prev.vimPlugins // {
    # commented because it's in the actual nixos packages now, but
    # leaving for reference
    # cmp-nvim-lsp-signature-help = prev.vimUtils.buildVimPluginFrom2Nix {
    #   pname = "cmp-nvim-lsp-signature-help";
    #   version = "2022-06-08";
    #   src = prev.fetchFromGitHub {
    #     owner = "hrsh7th";
    #     repo = "cmp-nvim-lsp-signature-help";
    #     rev = "8014f6d120f72fe0a135025c4d41e3fe41fd411b";
    #     sha256 = "1k61aw9mp012h625jqrf311vnsm2rg27k08lxa4nv8kp6nk7il29";
    #   };
    # };
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
    # Use rsync to auto sync files for "remote dev"
    # rsync-nvim = prev.vimUtils.buildVimPluginFrom2Nix {
    #   pname = "rsync-nvim";
    #   version = "2023-10-02";
    #   src = prev.fetchFromGitHub {
    #     owner = "OscarCreator";
    #     repo = "rsync.nvim";
    #     rev = "bc5789e73083692af2a21c72216d0b5985b929e3";
    #     sha256 = "sha256-4wGHDBOmBJEDR0qXpkj3mzlKsD+ScRj/KmsnET8tmEc=";
    #   };
    # };
    # rsync-nvim = prev.vimUtils.buildVimPlugin {
    #   pname = "rsync-nvim";
    #   version = "2023-10-02";
    #   src = prev.fetchFromGitHub {
    #     owner = "OscarCreator";
    #     repo = "rsync.nvim";
    #     rev = "bc5789e73083692af2a21c72216d0b5985b929e3";
    #     sha256 = "sha256-4wGHDBOmBJEDR0qXpkj3mzlKsD+ScRj/KmsnET8tmEc=";
    #   };
    #   buildInputs = [ prev.cargo prev.openssl ];
    #   buildPhase = ''
    #     make build
    #   '';
    # };
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

  # don't need anymore because it's been updated
  #micromamba = prev.callPackage ./micromamba.nix { };
  
# NOTE: I have no IDEA: why passing pkgs final versus prev works, but if I don't
# pass final, then my own packages can't require each-other. It seems like this
# should be recursive but....nix for you I guess?
} // import ../pkgs { pkgs = final; lib = inputs.nixpkgs-unstable.lib; }
