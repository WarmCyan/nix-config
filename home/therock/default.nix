# therock, home configuration for homeserver

{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
  ];

  home.packages = with pkgs; [
    tcpdump
  ];
}
