# phantom, home configuration for primary desktop

{ pkgs, lib, ... }:
{
  imports = [
    ../common/cli-core/configs.nix
    ../common/cli-core/nvim
    #../common/dev
    #../common/beta
    #../common/vscode
  ];
  
  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
  };

  home.packages = with pkgs; [
    powerline-fonts
  ];

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
}
