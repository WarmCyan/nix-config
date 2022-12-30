# Things I want:
# in the middle, music controls
# on the left, right before the workspaces, a terminal button
# on the right, date, time, IP-addr (global and local)? battery if applicable,
# vol

# TODO: clicking on amethyst brings up "rofi start menu"

{ pkgs, lib, ... }:
let
  cPrimary = "#FF9866"; # pleasent bright peach
  cWarmDark = "#353432";
  cBackground = "#232222";
in {
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
        modules-right = "date sepRL21 time";

        radius = 0;
        # radius-top = "0.0";
        # radius-bottom = "0.0";

        background = "${cBackground}";

        line-size = 2;
        line-color = "#FF0000";

        padding = 0;
        module-margin = 0;

        scroll-up = "i3wm-wsnext";
        scroll-down = "i3wm-wsprev";
      };


      "module/launcher-distro-icon" = {
        type = "custom/script";
        exec = "name=$(${pkgs.nettools}/bin/hostname) && ${pkgs.coreutils}/bin/echo \"\${name^}\"";
        interval = 99999;
        label="%output%";
        format = "  <label>"; # uf313 (in vim, use insert mode ctrl+v)
        format-foreground = "${cPrimary}";
        format-background = "${cWarmDark}";
        format-padding = 2;
        format-font = 4;
      };

      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;
        strip-wsnumbers=false;
        format = "<label-state> <label-mode>";
        format-background = "${cBackground}";

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

        label-focused-underline = "${cPrimary}";
        format-font = 5;
        #label-focused-underline-color = "#FF0000";
      };

      "module/time" = {
        type = "internal/date";
        interval = "1.0";
        time = "%H:%M:%S";

        format = "<label>";
        format-padding = 1;
        format-background = "${cPrimary}";
        format-foreground = "${cBackground}";
        format-font = 2;
        label = "%time%";
      };

      "module/date" = {
        type = "internal/date";
        interval = "60.0";
        date = "%Y-%m-%d";

        format = "<label>";
        format-padding = 1;
        format-background = "${cBackground}";
        format-foreground = "${cPrimary}";
        format-font = 2;
        label = "%date%";
        # https://github.com/vivien/i3blocks-contrib/blob/master/calendar/calendar
        # TODO: I don't think this actually works, not every module is
        # clickable. I will probably have to make a custom script module for
        # this one.
        click-left = "${pkgs.i3}/bin/i3-msg -q \"exec ${pkgs.yad}/bin/yad --calendar --undecorated --fixed --close-on-unfocus --no-buttons > /dev/null\"";
      };

      "module/sepLR01" = {
        type = "custom/text";
        content = " "; # ue0bc
        content-foreground = "${cWarmDark}";
        content-background = "${cBackground}";
        content-font = 3;
      };
      "module/sepRL21" = {
        type = "custom/text";
        content = " "; # ue0be
        content-foreground = "${cPrimary}";
        content-background = "${cBackground}";
        content-font = 3;
      };
    };
  };
}
