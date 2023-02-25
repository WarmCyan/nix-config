{ pkgs, lib, ... }:
let 
  caps = "Mod5";
  win = "Mod4";
  alt = "Mod1";
in
{
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

        "${win}+l" = "exec betterlockscreen --lock --blur";

        "${caps}+c" = "exec firefox";

        "${caps}+m" = "exec pcmanfm -n";

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
          command = "${pkgs.feh}/bin/feh --bg-fill ~/.background-image";
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

      # floating kitty terminal (see floating terminal in keybinds)
      for_window [class="kitty-floating"] floating toggle

      # bug from yad that was never fixed https://sourceforge.net/p/yad-dialog/tickets/301/
      for_window [class="Yad"] floating enable
    '';
  };
}

