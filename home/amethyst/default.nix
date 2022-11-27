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

{ pkgs, lib, ... }:
let 

  # i3
  caps = "Mod5";
  win = "Mod4";
  alt = "Mod1";

  # polybar
  bg = "#232222";
  fg = "#FFFFFF";
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
    # powerline-fonts
    # nerdfonts

    gimp
    feh
    
    betterlockscreen

    dunst

    glances
    nvtop
    # xsensors
    psensor
    
    obsidian

    pcmanfm
  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
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
    };
  };

  programs.rofi = {
    enable = true;
  };

  #programs.dconf.enable = true; # required for easyeffects to work?
  # https://github.com/NixOS/nixpkgs/issues/158476

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    #package = pkgs.i3-gaps;

    config = rec {
      modifier = caps;
      bars = [ ];

      fonts = {
        names = [ "Iosevka Nerd Font" ];
        style = "Bold";
        size = 11.0;
      };

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

      terminal = "${pkgs.kitty}/bin/kitty";

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

        "XF86AudioMute" = "exec amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";

        # https://github.com/i3/i3/issues/3343, for_window doesn't work for
        # containers, so the title format doesn't get applied.
        "${caps}+v" = "split v, focus parent, title_format \"█<span size='smaller'>  %title</span>\", focus child";

        
        #"${alt}+Tab" = "exec rofi -show window -kb-accept-entry '!Alt+Tab' -kb-element-next 'Alt+Tab'"; #-kb-element-previous 'Alt+Shift+Tab'";
      };
      
      startup = [
        # {
        #   command = "betterlockscreen -u ~/.background-image --fx blur --blur 1.0";
        #   always = false;
        #   notification = false;
        # }
        # 1, 3, 10, 1

        # for some weird reason, it starts with an odd set of workspaces open
        # (10 on the main one), so rejigger them a bit.
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }
        {
          command = "exec i3-msg workspace 3";
          always = true;
          notification = false;
        }
        {
          command = "exec i3-msg workspace 10";
          always = true;
          notification = false;
        }
        {
          command = "exec i3-msg workspace 1";
          always = true;
          notification = false;
        }
        
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
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

      #for_window [class=".*"] title_format "█<span size='smaller'>  %title</span>"  #ue0be
      #for_window [class=".*"] title_format "█  %title"  #ue0be
      #for_window [class=".*"] title_format "█  %title"  #ue0be
      #for_window [class=".*"] title_format "█<span size='smaller'>  %title</span>"  #ue0c6
      for_window [all] title_format "█<span size='smaller'>  %title</span>"  #ue0c6
      #for_window [class=".*"] normal 0px
    '';
  };

  # test by manually running `polybar -l info`
  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      #i3GapsSupport = true;
      alsaSupport = true;
      mpdSupport = true; #mpd_clientlib = pkgs.mpd_clientlib;
      i3Support = true; i3 = pkgs.i3; 
    };

    script = /* bash */ ''for m in $(polybar --list-monitors | ${pkgs.coreutils-full}/bin/cut -d":" -f1); do PATH=$PATH:${pkgs.i3}/bin MONITOR="$m" polybar -q -r top & done'';
    #script = "for m in $(polybar --list-monitors | cut -d':' -f1); do PATH=$PATH:${pkgs.i3}/bin MONITOR=$m polybar -q -r top & done";

    config = {
      "settings" = {
        screenchange-reload = true;

        compositing-background = "source";
        compositing-foreground = "over";
        compositing-overline = "over";
        comppositing-underline = "over";
        compositing-border = "over";

        pseudo-transparency = "false";
      };

      "bar/top" = {
        monitor = "\${env:MONITOR}";
        bottom = false;
        fixed-center = true;
        height = 25;
        offset-x = "1%";
        width = "100%";

        locale = "en_US.UTF-8";
        
        # don't forget, annoyingly, when referencing these fonts it's 1-based
        # instead of 0-based...using font-4 means setting format-font = 5, etc.
        font-0 = "Iosevka Nerd Font:pixelsize=12;3";
        font-1 = "Iosevka Nerd Font:style=Bold:size=12;3";
        font-2 = "Iosevka Nerd Font:pixelsize=20;3";
        font-3 = "Iosevka Nerd Font:pixelsize=15;3";
        
        font-4 = "Iosevka Nerd Font:size=12;3";
        
        # font-0 = "Droid Sans Mono Slashed for Powerline:size=12;3";
        # font-1 = "Droid Sans Mono Slashed for Powerline:style=Bold:size=12;3";
        
        modules-left = "launcher-distro-icon sepLR01 i3";
        modules-center = "";
        modules-right = "sepRL21 time";

        radius = 0;
        # radius-top = "0.0";
        # radius-bottom = "0.0";

        background = "#232222";

        line-size = 2;
        line-color = "#FF0000";

        padding = 0;
        module-margin = 0;

        scroll-up = "i3wm-wsnext";
        scroll-down = "i3wm-wsprev";
      };


      "module/launcher-distro-icon" = {
        type = "custom/text";
        content = "  Amethyst"; # uf313 (in vim, use insert mode ctrl+v)
        content-foreground = "#FF9866";
        content-background = "#353432";
        content-padding = 2;
        content-font = 4;
      };

      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;
        strip-wsnumbers=false;
        format = "<label-state> <label-mode>";
        format-background = "#232222";

        label-unfocused = "%index%";
        label-focused = "%index%";
        label-visible = "%index%";
        label-inactive = "%index%";
        
        label-focused-font = 5;
        label-unfocused-font = 5;
        label-visible-font = 5;
        label-inactive-font = 5;
        #label-visible = "%index% ";

        label-focused-padding = 1;
        label-unfocused-padding = 1;
        label-visible-padding = 1;
        label-inactive-padding = 1;

        label-focused-underline = "#FF9866";
        format-font = 5;
        #label-focused-underline-color = "#FF0000";
      };

      "module/time" = {
        type = "internal/date";
        interval = "1.0";
        time = "%H:%M:%S";

        format = "<label>";
        format-padding = 1;
        format-background = "#FF9866";
        format-foreground = "#232222";
        format-font = 2;
        label = "%time%";
      };

      "module/sepLR01" = {
        type = "custom/text";
        content = " "; # ue0bc
        content-foreground = "#353432";
        content-background = "#232222";
        content-font = 3;
      };
      "module/sepRL21" = {
        type = "custom/text";
        content = " "; # ue0be
        content-foreground = "#FF9866";
        content-background = "#232222";
        content-font = 3;
      };
    };
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
