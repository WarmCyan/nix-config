{ pkgs, ... }:
let
  inherit (builtins) readFile;
in
{
  home.packages = with pkgs; [

    shellcheck
    shfmt

    
    pre-commit
    micromamba
  ];

  home.file.".mambarc".text = ''
   channels:
   - conda-forge
  '';
}
