# planet, home configuration for work linux laptop

{ pkgs, lib, nixgl, config, ... }:
let 
  caps = "Mod5";
  win = "Mod4";
  alt = "Mod1";

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
    #../common/vscode
    ../common/beta
  ];

  # programs.neovim = {
  #   # package = pkgs.stable.neovim;
  #
  #   extraPackages = lib.mkForce [ ];
  # };
  
  home.packages = with pkgs; [
    zotero
    python311
    python311Packages.pip
    python311Packages.argcomplete

    gnumake
    unstable.obsidian
    jq

    mystmd

    gimp
    drawio
    inkscape

    powerline-fonts
    # (nerdfonts.override { fonts = [ "DroidSansMono" "Iosevka" ]; })
    nerd-fonts.droid-sans-mono
    nerd-fonts.iosevka

    zeal
    cg
    tag
    #pluto

    # firefox
  ];

  fonts.fontconfig.enable = true;

  programs.kitty = {
    package = (config.lib.nixGL.wrap pkgs.kitty);
    enable = true;
    theme = "Gruvbox Material Dark Hard";
    shellIntegration.mode = "disabled";
    #theme = "Everforest Dark Hard";
    settings = {
      shell = "${pkgs.zsh}/bin/zsh";
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
  
  # programs.librewolf = {
  programs.firefox = {
    # https://nixos.wiki/wiki/Librewolf
    enable = true;
    # package = pkgs.unstable.librewolf;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisplayBookmarksToolbar = "never";
      Preferences = {
        "privacy.resistFingerprinting.letterboxing" = true;
        "browser.safebrowsing.downloads.enabled" = true;
        "browser.compactmode.show" = true;
        "cookiebanners.service.mode" = 2;
        "privacy.donottrackheader.enabled" = true;
      };
      ExtensionSettings = {
        # go to about:support to find extension IDs
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          installation_mode = "force_installed";
        };
        "search@kagi.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  

  programs.eww = {
    enable = true;
    #package = pkgs.eww-wayland;
    package = pkgs.eww;
    configDir = ./ewwconfig;
  };

  services.dunst = {
    enable = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    #package = null;
    package = pkgs.unstable.sway;
    checkConfig = false;
    config = rec {
      modifier = caps;
      # bars = [ ];

      # fonts = {
      #   names = [ "Iosevka Nerd Font" ];
      #   style = "Bold";
      #   size = 11.0;
      # };

      window = {
        border = 1;
        hideEdgeBorders = "smart";
      };
      floating = {
        border = 1;
      };

      # gaps = {
      #   inner = 10;
      #   outer = 5;
      # };

      colors = {
        focused = {
          border = "#FF9866FF";
          background = "#FF9866FF";
          text = "#000000";
          indicator = "#FF000000";
          childBorder = "#FF9866FF";
        };
        unfocused = {
          border = "#343332FF";
          background = "#343332FF";
          text = "#FFFFFF";
          indicator = "#FF000000";
          childBorder = "#343332FF";
        };
        focusedInactive = {
          border = "#343332FF";
          background = "#343332FF";
          text = "#FFFFFF";
          indicator = "#FF000000";
          childBorder = "#343332FF";
        };
      };

      # terminal = "${pkgs.kitty}/bin/kitty";
      # terminal = "/usr/bin/kitty";
      terminal = "kitty";

      keybindings = lib.mkOptionDefault {

        #"${caps}+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "${caps}+Return" = "exec ${(config.lib.nixGL.wrap pkgs.kitty)}/bin/kitty";
        #"${caps}+Return" = "kitty";
        "${win}+Return" = "exec /usr/bin/foot";

        # floating terminal (see float toggle in extraconfig)
        "${caps}+Shift+Return" = "exec --no-startup-id ${(config.lib.nixGL.wrap pkgs.kitty)}/bin/kitty --class kitty-floating";

        # local docs browser
        "${caps}+slash" = "exec ${pkgs.zeal}/bin/zeal";

        # hjkl move focus between windows
        "${caps}+h" = "focus left";
        "${caps}+j" = "focus down";
        "${caps}+k" = "focus up";
        "${caps}+l" = "focus right";
        
        # hjkl window movement
        "${caps}+Shift+h" = "move left";
        "${caps}+Shift+j" = "move down";
        "${caps}+Shift+k" = "move up";
        "${caps}+Shift+l" = "move right";

        # move entire workspace
        "${caps}+Control+h" = "move workspace to output left";
        "${caps}+Control+l" = "move workspace to output right";
        
        "${caps}+q" = "kill";

        "${win}+l" = "exec betterlockscreen --lock blur";

        "${caps}+c" = "exec ${pkgs.firefox}/bin/firefox";

        "${caps}+m" = "exec pcmanfm -n";

        # "XF86AudioMute" = "exec amixer set Master toggle";
        # "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        # "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";

        # https://github.com/i3/i3/issues/3343, for_window doesn't work for
        # containers, so the title format doesn't get applied.
        "${caps}+v" = "split v, focus parent, title_format \"█<span size='smaller'>  %title</span>\", focus child";

        "${caps}+d" = "exec ${pkgs.rofi}/bin/rofi -show run -config ~/.local/share/rofi/themes/squared-everforest.rasi";
        
        # TODO: there's still a white/blue styled selected option
        # TODO: this doesn't allow enter to accept entry
        "${alt}+Tab" = "exec ${pkgs.rofi}/bin/rofi -show window -kb-accept-entry '!Alt+Tab' -kb-element-next 'Alt+Tab' -config ~/.local/share/rofi/themes/squared-everforest.rasi"; #-kb-element-previous 'Alt+Shift+Tab'";

        
        "${caps}+0" = "workspace number 10";
        "${caps}+Shift+0" = "move container to workspace number 10";

        "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
      };

      # inside ~/.config/xkb/symbols/custom:
      # xkb_symbols "basic" {
      #   include "us"
      #   name[Group1]= "English (US Custom)";
      #   key <CAPS> { [ Hyper_L ] };
      #   modifier_map Mod5 { Hyper_L };
      #   modifier_map Mod4 { Super_L };
      # };
      input = {
        "*" = {
          xkb_layout = "custom";
          #xkb_options = "caps:hyper";
        };
      };

      output = {
        DP-5 = {
          mode = "2560x1440@99.946Hz";
          pos = "1080 0";
        };
        DP-3 = {
          mode = "1920x1080";
          transform = "90";
          pos = "0 0";
        };
        eDP-1 = {
          disable = "";
        };
      };
      
    };
    extraConfig = ''
      # floating kitty terminal (see floating terminal in keybinds)
      for_window [app_id="kitty-floating"] floating toggle
      
      # don't automatically focus the window the mouse is over
      focus_follows_mouse no
    '';
  };

  #programs.vscode = {
  #  enable = true;
  #  extensions = with pkgs.vscode-extensions; lib.mkForce [
  #    vscodevim.vim
  #  ];
  #};
}
