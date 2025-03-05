# NOTE: explore https://github.com/adi1090x/rofi for good rofi stuff!

{ pkgs, lib, colorActive ? "FF9866", colorInactive ? "343332", ... }:
let 
  #caps = "Mod5";
  caps = "Mod3";
  win = "Mod4";
  alt = "Mod1";

  inherit (builtins) readFile;
in
{
  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;

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
          border = "#${colorActive}FF";
          background = "#${colorActive}FF";
          text = "#000000";
          indicator = "#FF000000";
          childBorder = "#${colorActive}FF";
        };
        unfocused = {
          border = "#${colorInactive}FF";
          background = "#${colorInactive}FF";
          text = "#FFFFFF";
          indicator = "#FF000000";
          childBorder = "#${colorInactive}FF";
        };
        focusedInactive = {
          border = "#${colorInactive}FF";
          background = "#${colorInactive}FF";
          text = "#FFFFFF";
          indicator = "#FF000000";
          childBorder = "#${colorInactive}FF";
        };
      };

      terminal = "${pkgs.kitty}/bin/kitty";

      keybindings = lib.mkOptionDefault {

        "${caps}+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "${alt}+Return" = "exec i3-sensible-terminal";  # emergency broken-caps-lock

        # floating terminal (see float toggle in extraconfig)
        "${caps}+Shift+Return" = "exec --no-startup-id ${pkgs.kitty}/bin/kitty --class kitty-floating";

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

        # "${win}+l" = "exec betterlockscreen --lock blur";

        "${caps}+c" = "exec librewolf";

        "${caps}+m" = "exec pcmanfm -n";

        "XF86AudioMute" = "exec amixer set Master toggle";
        "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";

        # https://github.com/i3/i3/issues/3343, for_window doesn't work for
        # containers, so the title format doesn't get applied.
        "${caps}+v" = "split v, focus parent, title_format \"█<span size='smaller'>  %title</span>\", focus child";

        "${caps}+d" = "exec ${pkgs.rofi}/bin/rofi -show run -config ~/.local/share/rofi/themes/squared-everforest.rasi";
        
        # TODO: there's still a white/blue styled selected option
        # TODO: this doesn't allow enter to accept entry
        "${alt}+Tab" = "exec ${pkgs.rofi}/bin/rofi -show window -kb-accept-entry '!Alt+Tab' -kb-element-next 'Alt+Tab' -config ~/.local/share/rofi/themes/squared-everforest.rasi"; #-kb-element-previous 'Alt+Shift+Tab'";
      };
      
      startup = [
        {
          command = "${pkgs.feh}/bin/feh --bg-fill ~/.background-image";
          always = true;
          notification = false;
        }
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

      # floating kitty terminal (see floating terminal in keybinds)
      for_window [class="kitty-floating"] floating toggle

      # bug from yad that was never fixed https://sourceforge.net/p/yad-dialog/tickets/301/
      for_window [class="Yad"] floating enable
    '';
  };

  home.file.".local/share/rofi/themes/squared-everforest.rasi".text = readFile ./squared-everforest.rasi;
}

