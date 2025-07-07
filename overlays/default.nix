# TODO: we need probably an exclusively unstable set of overlays and stable set?
{ inputs, outputs, ... }:
let
  cgit_theme_text = builtins.readFile ./gruvbox_theme.css;
in
{
  custom-pkgs = final: _prev: import ../pkgs { pkgs = final; lib = outputs.lib; };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
      # obsidian currently breaks without this
      config.permittedInsecurePackages = [ "electron-25.9.0" ];
    };
  };

  # https://github.com/NixOS/nixpkgs/issues/262000
  fix-hanging-debugpy = final: prev: {
    python3 = prev.python3.override {
      packageOverrides = pfinal: pprev: {
        debugpy = pprev.debugpy.overrideAttrs (oldAttrs: {
          pytestCheckPhase = "true";
        });
      };
    };
    python3Packages = final.python3.pkgs;
  };


  modifications = final: prev: {
    vimPlugins = prev.vimPlugins // {

      # make it easier to add in unstable vim plugins without needing to
      # explicitly ref pkgs.unstable.vimPlugins
      unstable = final.unstable.vimPlugins;
      
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
      # allow C-. and C-, to swap sibling nodes quickly
      sibling-swap = prev.vimUtils.buildVimPlugin {
        pname = "sibling-swap";
        version = "2023-10-05";
        src = prev.fetchFromGitHub {
          owner = "Wansmer";
          repo = "sibling-swap.nvim";
          rev = "58b256f2a7def9b63be275b373c748c012b3a604";
          sha256 = "sha256-tS0eG0JbvfhX9BIkmfC3u+dIcZvuQvYsB7vw25JX/gg=";
        };
      };
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

    tt-rss-theme-feedly = prev.tt-rss-theme-feedly.overrideAttrs
      (_oldAttrs: rec {
        src = prev.fetchFromGitHub {
          owner = "levito";
          repo = "tt-rss-feedly-theme";
          rev = "9b50cee70e1ed77d27a273e267c2f50455a23e6f";
          sha256 = "sha256-0U2APDh++U7qWwv9ky9nEZ8WvsSbWBTSUwqQqkIkaqU=";
        };
      });
      

    cgit-themed = prev.cgit.overrideAttrs
      (_oldAttrs: {
        postInstall = _oldAttrs.postInstall + ''
          echo "${cgit_theme_text}" >> $out/cgit/cgit.css
        '';
      });
  };
  
  # don't need anymore because it's been updated
  #micromamba = prev.callPackage ./micromamba.nix { };
  
# NOTE: I have no IDEA: why passing pkgs final versus prev works, but if I don't
# pass final, then my own packages can't require each-other. It seems like this
# should be recursive but....nix for you I guess?
}
