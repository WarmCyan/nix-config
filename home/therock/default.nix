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

  home.file."generate-warmcyan.sh".text = /* bash */ ''
  #!/usr/bin/env bash

  if [[ ! -d /home/dwl/lazuli ]]; then
    git clone git@github.com:WarmCyan/lazuli.git
  fi

  if [[ ! -d /home/dwl/lab/obsidian-web-exporter ]]; then
    pushd /home/dwl/lab
    git clone git@github.com:WarmCyan/obsidian-web-exporter.git
    popd
  fi

  pushd /home/dwl/lazuli
  git pull
  popd

  pushd /home/dwl/lab/obsidian-web-exporter
  git pull
  rm -rfd /www/html/*
  ./export.sh /home/dwl/lazuli /www/html
  chgrp -R nginx /www/html
  popd
  '';

  home.file."publish-warmcyan.sh".text = /* bash */ ''
  #!/usr/bin/env bash

  if [[ ! -d /home/dwl/lab/warmcyan.eco ]]; then
    pushd /home/dwl/lab
    git clone git@github.com:WarmCyan/warmcyan.eco.git
    popd
  fi

  pushd /home/dwl/lazuli
  git pull
  popd

  pushd /home/dwl/lab/obsidian-web-exporter
  git pull
  rm -rf /home/dwl/lab/warmcyan.eco/*
  ./export.sh /home/dwl/lazuli /home/dwl/lab/warmcyan.eco
  export GPG_TTY=$(tty)
  git commit -S
  git push
  popd
  '';
}
