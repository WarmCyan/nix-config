# amethyst, home configuration for BEAST MAIN PC!

# https://github.com/Th0rgal/horus-nix-home/blob/master/configs/i3.nix
# https://github.com/WildfireXIII/iris-core/blob/master/de/i3/config
# https://github.com/srid/nix-config/blob/705a70c094da53aa50cf560179b973529617eb31/nix/home/i3.nix

{ pkgs, lib, ... }:
let 
  caps = "Mod5";
  win = "Mod4";
  alt = "Mod1";
in
{
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/vscode
    ../common/beta
  ];

  home.packages = with pkgs; [
    # flameshot
    # easyeffects
    arandr
    qpwgraph
    pavucontrol
    powerline-fonts

    gimp
    feh
    
    betterlockscreen

    dunst
  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Droid Sans Mono Slashed for Powerline";
      font_size = "9.0";
      background = "#050505";
      confirm_os_window_close = "0";
    };
  };

  #programs.dconf.enable = true; # required for easyeffects to work?
  # https://github.com/NixOS/nixpkgs/issues/158476

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;

    config = rec {
      modifier = caps;

      keybindings = lib.mkOptionDefault {

        "${caps}+Return" = "exec ${pkgs.kitty}/bin/kitty";

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

        "${caps}+q" = "kill";

        "${win}+l" = "exec betterlockscreen --lock --blur";
      };
      
      startup = [
        # {
        #   command = "betterlockscreen -u ~/.background-image --fx blur --blur 1.0";
        #   always = false;
        #   notification = false;
        # }
        {
          command = "${pkgs.feh}/bin/feh --bg-scale ~/.background-image";
          always = true;
          notification = false;
        }
        # TODO: need a set-wallpaper command, that runs the betterlockscreen -u .background-image --fx blur
        # cache thingy
      ];
    };

    extraConfig = ''
      # don't automatically focus the window the mouse is over
      focus_follows_mouse no
    '';
  };

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
