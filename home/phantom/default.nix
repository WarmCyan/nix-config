# phantom, home configuration for primary desktop

{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/beta
    ../common/vscode
  ];
  
  home.packages = with pkgs; [
    flameshot
  ];
}
