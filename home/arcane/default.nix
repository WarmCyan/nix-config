# arcane, home configuration for work linux workstation

{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/vscode
  ];
  
  home.packages = with pkgs; [
    zotero
  ];
}
