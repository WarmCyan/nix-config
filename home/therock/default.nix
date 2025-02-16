# therock, home configuration for homeserver

{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    #../common/dev
  ];

  home.packages = with pkgs; [
    tcpdump
  ];

  programs.git.signing.format = "openpgp";

  programs.gpg = {
    enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
