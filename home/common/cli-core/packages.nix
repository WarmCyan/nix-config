{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # -- Basic utils --
    tree      # list a directory tree recursively, looks nicer than ls in select situations
    ripgrep   # speedy grep written in rust
    fzf       # very effective fuzzy finder
    bat       # fancier cat
    rsync     # better file transfer than scp and cp
    zip       # gotta be able to work with .zips
    unzip     # gotta be able to work with .zips
    gnumake   # ability to run makefiles
    nix-search# faster than nix search

    # -- TUI tools --
    htop      # standard system cpu viewer
    bottom    # a cool-looking system viewer in rust
    ncdu      # disk usage, useful for discovering where all your diskspace went
    w3m       # terminal web browser

    # -- Fun, the spice of life :) --
    figlet    # output cool big terminal text
    cowsay    # what does the cow say?
    sl        # no environment is complete without it
    lolcat    # tool to vomit rainbow colors for input text
    tty-clock # best terminal clock around
    neofetch  # gotta show off my distro

    # -- My stuff! --
    td-state  # todo-status cycler, used in my nvim config with shift-t
    tools     # check which of my tools are installed (and also reminders of what my tools are!)
  ];
}
