# NOTE: explore https://github.com/adi1090x/rofi for good rofi stuff!

{ config, pkgs, lib, ... }:
with lib;
let 
  #caps = "Mod5";
  caps = "Mod3";
  win = "Mod4";
  alt = "Mod1";

  inherit (builtins) readFile;

  cfg = config.desktop.i3;
in
{

  options.desktop.i3 = {
    enable = mkEnableOption "Customized I3 desktop";
    colorActive = mkOption {
      type = types.str;
      default = "FF9866";
    };
    colorInactive = mkOption {
      type = types.str;
      default = "343332";
    };
    browser = mkOption {
      type = types.str;
      default = "librewolf";
    };
  };


  config = mkIf cfg.enable {
    
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
            border = "#${cfg.colorActive}FF";
            background = "#${cfg.colorActive}FF";
            text = "#000000";
            indicator = "#FF000000";
            childBorder = "#${cfg.colorActive}FF";
          };
          unfocused = {
            border = "#${cfg.colorInactive}FF";
            background = "#${cfg.colorInactive}FF";
            text = "#FFFFFF";
            indicator = "#FF000000";
            childBorder = "#${cfg.colorInactive}FF";
          };
          focusedInactive = {
            border = "#${cfg.colorInactive}FF";
            background = "#${cfg.colorInactive}FF";
            text = "#FFFFFF";
            indicator = "#FF000000";
            childBorder = "#${cfg.colorInactive}FF";
          };
        };

        terminal = "${pkgs.kitty}/bin/kitty";

        keybindings = lib.mkOptionDefault {
        # keybindings = {

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

          "${caps}+c" = "exec ${cfg.browser}";

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
  };
}

