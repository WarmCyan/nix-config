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
    # easyeffects
  ];

  #programs.dconf.enable = true; # required for easyeffects to work?
  # https://github.com/NixOS/nixpkgs/issues/158476
}
