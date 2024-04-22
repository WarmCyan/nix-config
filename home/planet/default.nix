# planet, home configuration for work linux laptop

{ pkgs, lib, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
    #../common/vscode
    ../common/beta
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

    gnumake
  ];

  #programs.vscode = {
  #  enable = true;
  #  extensions = with pkgs.vscode-extensions; lib.mkForce [
  #    vscodevim.vim
  #  ];
  #};
}
