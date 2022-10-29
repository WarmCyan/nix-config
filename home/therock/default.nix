{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
  ];

  home.packages = with pkgs; [
    testing2
  ];
}
