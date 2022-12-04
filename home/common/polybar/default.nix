{ pkgs, lib, ... }:
{
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
}
