# workbench/radio laptop

# https://github.com/Th0rgal/horus-nix-home/blob/master/configs/i3.nix
# https://github.com/WildfireXIII/iris-core/blob/master/de/i3/config
# https://github.com/srid/nix-config/blob/705a70c094da53aa50cf560179b973529617eb31/nix/home/i3.nix

# https://gvolpe.com/blog/xmonad-polybar-nixos/
# https://github.com/nix-community/home-manager/blob/master/modules/services/polybar.nix
# see https://github.com/adi1090x/polybar-themes for inspiration (I really like
# the shapes one)

# https://github.com/Th0rgal/horus-nix-home
# https://github.com/Th0rgal/horus-nix-home/blob/master/configs/polybar.nix

# https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points
# https://github.com/adi1090x/polybar-themes/blob/master/simple/shapes/config.ini



# https://wiki.archlinux.org/title/i3#Tips_and_tricks
# https://github.com/ray-pH/polybar-cava
# https://github.com/DaveDavenport/Rofication

# Another good config set to pay attention to for audio stuff:
# https://github.com/dnordstrom/dotfiles

{ pkgs, lib, ... }:
{
  imports = [
    ../common/cli-core

    ../common/i3
    ../common/polybar
    ../common/kitty
  ];

  home.packages = with pkgs; [
    # -- audio --
    qpwgraph          # pipewire graphical controls (qjackctl but for pipewire)
    pavucontrol       # detailed audio settings
    audacity          # basic audio editing
    mic-monitor       # custom tool to turn mic monitor on and off

    # -- utils --
    flameshot         # screenshot tool
    pcmanfm           # file explorer
    feh               # image viewer/desktop wallpaper
    dunst             # notifications
    betterlockscreen  # super cool lock screen based on i3lock
    arandr            # multi-monitor configuration tool
    xclip             # clipboard tool
    vlc               # video/audio player
    # wineWowPackages.unstableFull  # NOTE: necessary for several of the windows vst bridges
    ffmpeg            # video conversion/editing CLI
    imagemagick       # image conversion/editing CLI
    dnsutils          # includes nslookup
    usbutils          # includes lsusb
    wireguard-tools   # includes wg
    tcpdump           # watch/debug packets on network interfaces
    drawio            # diagramming tool

    # -- other --
    libreoffice-qt      # office suite
    obsidian            # knowledge management
    python311           # a system (user) python so I can quickly run/test stuff

    gcc

    cg
    chromium
    screen
  ];

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
    extraConfig = ''
        # workspace 1 output DP-4
        # workspace 2 output DP-1
        # workspace 3 output DP-2
    '';
  };

  desktop = {
    i3.enable = true;
    i3.colorActive = "7daea3";
    polybar.enable = true;
    polybar.colorPrimary = "7daea3";
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
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      #package = pkgs.libsForQt5.qtstyleplugins;
      name = "adwaita-dark";
    };
  };

  # NOTE: that via the options listed in
  # https://rycee.gitlab.io/home-manager/options.html, we also have to enable
  # "services.udisks2.enable = true" in the system config for this to work on
  # NixOS
  # (usb automounting)
  services.udiskie = {
    enable=true;
    settings = {
      program_options = {
        file_manager = "${pkgs.pcmanfm}/bin/pcmanfm";
      };
    };
  };

  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark-hard";
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


  home.file.".config/betterlockscreenrc".text = ''
    fx_list=(blur)
    wallpaper_cmd=""
    blur_level=1

    locktext="Hi Nathan!"
    
    loginbox=FFFFFF22
    loginshadow=FFFFFF11
    font="sans-serif"
    ringcolor=ffffffff
    insidecolor=00000000
    separatorcolor=00000000
    ringvercolor=ffffff99
    insidevercolor=00000000
    ringwrongcolor=ffffff99
    insidewrongcolor=d28c3dee
    timecolor=ffffffff
    time_format="%H:%M"
    greetercolor=ffffffff
    layoutcolor=ffffffff
    keyhlcolor=d28c3dee
    bshlcolor=d28c3dee
    verifcolor=ffffffff
    wrongcolor=d28c3dee
    modifcolor=d28c3dee
    bgcolor=000000ff
  '';
}
