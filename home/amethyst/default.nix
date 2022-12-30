# amethyst, home configuration for BEAST MAIN PC!

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
    ../common/dev
    ../common/vscode
    ../common/beta

    ../common/i3
    ../common/polybar

    ../common/discord
  ];

  home.packages = with pkgs; [
    # flameshot
    arandr
    
    # -- audio --
    qpwgraph          # pipewire graphical controls (qjackctl but for pipewire)
    pavucontrol       # detailed audio settings
    easyeffects       # live audio effects
    audacity          # basic audio editing
    helvum            # another graphical tool for pipewire (seems worse than qpwgraph)
    mic-monitor       # custom tool to turn mic monitor on and off
    alsa-scarlett-gui # gui controls for focusrite 2i2 gen 3
    
    # powerline-fonts
    # nerdfonts

    gimp
    feh
    
    betterlockscreen  # super cool lock screen based on i3lock

    dunst             # notifications

    glances
    nvtop
    # xsensors
    psensor
    dconf  # this is required so psensor can save changes to theme (think it's a gtk thing)
    
    obsidian

    pcmanfm

    python311


    flameshot

    # creative
    blender


  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
    #NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
  };

  programs.kitty = {
    enable = true;
    theme = "Gruvbox Material Dark Hard";
    #theme = "Everforest Dark Hard";
    settings = {
      font_family = "Droid Sans Mono Slashed for Powerline";
      font_size = "9.0";
      #background = "#050505";
      confirm_os_window_close = "0";
      color0 = "#151414"; # gruvbox's black is waaay too light
      remember_window_size = "no";
      initial_window_width = "100c";
      initial_window_height = "25c";
    };
  };

  programs.rofi = {
    enable = true;
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
