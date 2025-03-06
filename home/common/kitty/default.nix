{ pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;
    themeFile = "GruvboxMaterialDarkHard";
    shellIntegration.mode = "disabled";
    #theme = "Everforest Dark Hard";
    settings = {
      font_family = "DejaVus Sans Mono Slashed for Powerline";
      font_size = "10.0";
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
