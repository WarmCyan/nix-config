# arcane, home configuration for work linux workstation

{ pkgs, lib, nixgl, config, ... }:
let 
  #caps = "Mod5";
  caps = "Mod3";
  win = "Mod4";
  alt = "Mod1";

  colorActive = "F1B471";
  colorInactive = "343332";
  
  inherit (builtins) readFile;
in
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
    ../common/i3
  ];

  xsession = {
    profileExtra = /* bash */ ''
      eval `ssh-agent -s`
      export IAMPROFILE="hello"
      exec ${pkgs.kbd-capslock}/bin/kbd-capslock &
    '';

    windowManager.i3 = {
      package = (config.lib.nixGL.wrap pkgs.i3);

      config = rec {
        bars = [
          {
            position = "top";
            colors = {
              focusedWorkspace = {
                border = "#${colorActive}FF";
                background = "#${colorActive}FF";
                text = "#000000FF";
              };
            };
            statusCommand = "${pkgs.i3status}/bin/i3status -c /home/81n/i3status.conf";
          }
        ];
        
        #terminal = "${pkgs.kitty}/bin/kitty";
        keybindings = {
          "${caps}+c" = "exec firefox";

          "${caps}+slash" = "exec ${pkgs.zeal}/bin/zeal";
          "${win}+l" = "exec i3lock -i /home/81n/.lock-background-image.png";
        };
        startup = [
          {
            command = "${pkgs.kbd-capslock}/bin/kbd-capslock";
            always = true;
            notification = false;
          }
        ];
      };
      extraConfig = ''
        workspace 1 output DP-1
        workspace 2 output DP-2
      '';
    };
  };

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
  };

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


    cg
    kbd-capslock

    pcmanfm
    lxappearance
  ];
  
  # still no luck :(
  # programs.librewolf = {
  #   # https://nixos.wiki/wiki/Librewolf
  #   enable = true;
  #   # package = pkgs.unstable.librewolf;
  #   policies = {
  #     DisableTelemetry = true;
  #     DisableFirefoxStudies = true;
  #     DisplayBookmarksToolbar = "never";
  #     Preferences = {
  #       "privacy.resistFingerprinting.letterboxing" = true;
  #       "browser.safebrowsing.downloads.enabled" = true;
  #       "browser.compactmode.show" = true;
  #       "cookiebanners.service.mode" = 2;
  #       "privacy.donottrackheader.enabled" = true;
  #     };
  #     ExtensionSettings = {
  #       # go to about:support to find extension IDs
  #       "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
  #         install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
  #         installation_mode = "force_installed";
  #       };
  #       "search@kagi.com" = {
  #         install_url = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
  #         installation_mode = "force_installed";
  #       };
  #       "addon@darkreader.org" = {
  #         install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
  #         installation_mode = "force_installed";
  #       };
  #     };
  #   };
  # };
  #

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
