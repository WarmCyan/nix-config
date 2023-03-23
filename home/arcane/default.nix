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
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; lib.mkForce [
      vscodevim.vim
    ];
  };
}
