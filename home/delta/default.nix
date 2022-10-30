# delta, home configuration for primary laptop

{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/beta
    ../common/vscode
  ];
  
  home.packages = with pkgs; [
  ];
}
