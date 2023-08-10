# arcane, home configuration for work linux workstation

{ pkgs, lib, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/vscode
  ];

  # programs.neovim = {
  #   # package = pkgs.stable.neovim;
  #
  #   extraPackages = lib.mkForce [ ];
  # };
  
  home.packages = with pkgs; [
    zotero
    python311
    python311Packages.pip
    python311Packages.argcomplete

    ffmpeg
    inkscape

    asciinema
    asciinema-agg

    julia-bin
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; lib.mkForce [
      vscodevim.vim
    ];
  };
}
