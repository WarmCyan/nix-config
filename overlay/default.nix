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
  }; # // import ../pkgs/vim-plugins { pkgs = prev } # TODO: !!!
} # // import ../pkgs { pkgs = prev; } # TODO: !!!
