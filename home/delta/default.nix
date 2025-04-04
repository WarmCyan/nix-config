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
  };
  desktop = {
    i3 = {
      enable = true;
      colorActive = "667b59";
      colorInactive = "323433";
      browser = "firefox";
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
      package = pkgs.gnome.gnome-themes-extra;
      name = "Adwaita-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
    };
  };

  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark-hard";
    location = "top-left";
    yoffset = 25;
  };


  # https://github.com/nix-community/home-manager/issues/3113 (and psensor?)
  #programs.dconf.enable = true; # required for easyeffects to work?
  # https://github.com/NixOS/nixpkgs/issues/158476

  # NOTE: to generate the lockscreen image you need to separately run
  # betterlockscreen -u .background-image -l blur

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
  
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; lib.mkForce [
      vscodevim.vim
    ];
  };
}
