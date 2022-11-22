# amethyst, home configuration for BEAST MAIN PC!

{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/vscode
    ../common/beta
  ];

  home.packages = with pkgs; [
    # flameshot
  ];
}
