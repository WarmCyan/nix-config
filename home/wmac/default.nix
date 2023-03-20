# phantom, home configuration for primary desktop

{ pkgs, lib, ... }:

let
  inherit (builtins) readFile;
in
{
  imports = [
    ../common/cli-core/configs.nix
    ../common/cli-core/nvim
    ../common/dev
    ../common/beta
    ../common/vscode
  ];
  
  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    powerline-fonts
    coreutils  # otherwise we use mac's which are super broken (e.g. 'rm' doesn't support --preserve-root)
    bash  # not actually sure why this isn't already installed since we have it in cli-core configs


    # -- Basic utils --
    tree      # list a directory tree recursively, looks nicer than ls in select situations
    ripgrep   # speedy grep written in rust
    fzf       # very effective fuzzy finder
    bat       # fancier cat
    rsync     # better file transfer than scp and cp

    # -- TUI tools --
    htop      # standard system cpu viewer
    bottom    # a cool-looking system viewer in rust
    
    # -- Fun, the spice of life :) --
    figlet    # output cool big terminal text
    cowsay    # what does the cow say?
    sl        # no environment is complete without it
    neofetch  # gotta show off my distro
    
    # -- My stuff! --
    td-state  # todo-status cycler, used in my nvim config with shift-t
    tools     # check which of my tools are installed (and also reminders of what my tools are!)
    engilog   # my on-the-go brainstorming and thoughts engineering log tool

    # -- Making mac suck less --
    # karabiner-elements  # NOTE: I couldn't get this to work, had to install with brew. I still set the config down below
    # skhd # (same as above)
    
    # https://github.com/koekeishiya/yabai/issues/843
  ];

  # karabiner config to turn caps lock into hyper
  home.file.".config/karabiner/karabiner.json".text = readFile ./karabiner.json;
  home.file.".skhdrc".text = readFile ./skhdrc;

  home.homeDirectory = lib.mkForce "/Users/81n";
  
  programs.kitty = {
    enable = true;
    theme = "Gruvbox Material Dark Hard";
    #theme = "Everforest Dark Hard";
    settings = {
      font_family = "Droid Sans Mono Slashed for Powerline";
      font_size = "12.0";
      #background = "#050505";
      confirm_os_window_close = "0";
      color0 = "#151414"; # gruvbox's black is waaay too light
      remember_window_size = "no";
      initial_window_width = "100c";
      initial_window_height = "25c";
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; lib.mkForce [
      vscodevim.vim
    ];
  };
}
