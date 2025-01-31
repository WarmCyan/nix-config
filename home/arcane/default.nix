# arcane, home configuration for work linux workstation

{ pkgs, lib, nixgl, config, ... }:
{
  nixGL = {
    packages = nixgl.packages;
    defaultWrapper = "mesa";
  };
  
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/vscode
    ../common/beta
  ];

  # programs.neovim = {
  #   # package = pkgs.stable.neovim;
  #
  #   extraPackages = lib.mkForce [ ];
  # };

  fonts.fontconfig.enable = true;
  
  home.packages = with pkgs; [
    zotero
    python311
    python311Packages.pip
    python311Packages.argcomplete

    ffmpeg
    inkscape

    asciinema
    asciinema-agg

    julia-bin

    xclip

    gifify

    mystmd
    unstable.obsidian

    powerline-fonts
    (nerdfonts.override { fonts = [ "Iosevka" "Inconsolata" ]; })
    (config.lib.nixGL.wrap alacritty)
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; lib.mkForce [
      vscodevim.vim
    ];
  };

  programs.wezterm = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.wezterm);
  };

  programs.kitty = {
    package = (config.lib.nixGL.wrap pkgs.kitty);
    enable = true;
    # theme = "Gruvbox Material Dark Hard";
    themeFile = "GruvboxMaterialDarkHard";
    shellIntegration.mode = "disabled";
    #theme = "Everforest Dark Hard";
    settings = {
      shell = "zsh";
      # font_family = "Droid Sans Mono Slashed for Powerline";
      font_family = "DejaVus Sans Mono Slashed for Powerline";
      font_size = "10.0";
      #background = "#050505";
      confirm_os_window_close = "0";
      color0 = "#151414"; # gruvbox's black is waaay too light
      remember_window_size = "no";
      initial_window_width = "100c";
      initial_window_height = "25c";
      cursor_shape = "block";
      cursor_blink_interval = "0";

      # improve input latency
      # https://beuke.org/terminal-latency/#fn:2
      repaint_delay = "8";
      input_delay = "0";
      sync_to_monitor = "no";
    };
  };
}
