# delta, home configuration for primary laptop

{ pkgs, lib, config, ... }:
{
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/beta
    ../common/vscode
    
    ../common/i3
    ../common/polybar
    ../common/kitty

    ../common/music

    ../common/minimal-desktop
  ];
  
  home.packages = with pkgs; [
    
    # -- utils --
    flameshot         # screenshot tool
    pcmanfm           # file explorer
    feh               # image viewer/desktop wallpaper
    dunst             # notifications
    betterlockscreen  # super cool lock screen based on i3lock
    arandr            # multi-monitor configuration tool
    
    # -- other --
    unstable.obsidian
    python311
    dconf
    
    vlc
    # ymuse
    # mpdevil
    
    lxappearance  # don't actually use...

    engilog

    anki-bin

    sdrangel
    gqrx
    rtl-sdr

    usbutils

    julia-bin
    pluto
    pandoc
    jq

    # arduino-ide

    wireguard-tools

    zoom-us
    chromium
  ];

  # programs.bash.initExtra = ''
  #   if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -le 3 ]; then
  #     echo "YEEPPP"
  #     exec startx
  #   fi
  # '';
  # programs.bash.profileExtra = ''
  #   if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ] && [[ "$(tty)" == *"/dev/tty"* ]]; then
  #     exec startx
  #   fi
  # '';
  # programs.zsh.profileExtra = ''
  #   if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ] && [[ "$(tty)" == *"/dev/tty"* ]]; then
  #     exec startx
  #   fi
  # '';
  #
  # home.file.".xinitrc".text = ''
  #   if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
  #     eval $(dbus-launch --exit-with-session --sh-syntax)
  #   fi
  #   systemctl --user import-environment DISPLAY XAUTHORITY
  #
  #   if command -v dbus-update-activation-environment >/dev/null 2>&1; then
  #           dbus-update-activation-environment DISPLAY XAUTHORITY
  #   fi
  #
  #   ${pkgs.kbd-capslock}/bin/kbd-capslock
  #
  #   exec $HOME/.xsession
  # '';
  #
  #
  xsession.windowManager.i3 = {
    config = {
      startup = [
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
      ];
    };
  };
  desktop = {
    minimalX.enable = true;
    i3 = {
      enable = true;
      colorActive = "667b59";
      colorInactive = "323433";
      browser = "librewolf";
    };
    polybar = {
      enable = true;
      colorPrimary = "768b69";
      colorSecondary = "333532";
      colorBackground = "222322";
    };
  };
  
  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
    #NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
    gtk4.theme = config.gtk.theme;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "adwaita-dark";
    };
  };

  programs.rofi = {
    enable = true;
    # theme = "gruvbox-dark-hard";
    theme = "~/.local/share/rofi/themes/squared-everforest-upperleft.rasi";
    location = "top-left";
    yoffset = 25;
  };
  
  programs.librewolf = {
    # https://nixos.wiki/wiki/Librewolf
    enable = true;
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
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
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



  # https://github.com/nix-community/home-manager/issues/3113 (and psensor?)
  #programs.dconf.enable = true; # required for easyeffects to work?
  # https://github.com/NixOS/nixpkgs/issues/158476

  # NOTE: to generate the lockscreen image you need to separately run
  # betterlockscreen -u .background-image -l blur
}
