# therock, home configuration for homeserver

{ pkgs, ... }:
{
  imports = [
    ../common/cli-core
    #../common/dev
  ];

  home.packages = with pkgs; [
    tcpdump
    gpg-without-tty
  ];

  # programs.git.signing.format = "openpgp"; # not a thing until 25.05

  programs.gpg = {
    enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
