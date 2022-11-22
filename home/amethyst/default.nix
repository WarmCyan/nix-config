# amethyst, home configuration for BEAST MAIN PC!

{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
  ];

  home.packages = with pkgs; [
  ];
}
