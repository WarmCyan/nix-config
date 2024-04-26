# planet, home configuration for work linux laptop

{ pkgs, lib, ... }:
let 
  caps = "Mod5";
  win = "Mod4";
  alt = "Mod1";

  inherit (builtins) readFile;
in
{
  imports = [
    ../common/cli-core
    ../common/dev
    #../common/vscode
    ../common/beta
  ];

  # programs.neovim = {
  #   # package = pkgs.stable.neovim;
  #
  #   extraPackages = lib.mkForce [ ];
  # };
  
  home.packages = with pkgs; [
    zotero
    python311
    python311Packages.pip
    python311Packages.argcomplete

    gnumake
    unstable.obsidian
    jq
  ];

  programs.eww = {
    enable = true;
    package = pkgs.eww-wayland;
    configDir = ./ewwconfig;
  };

  services.dunst = {
    enable = true;
  };

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = rec {
      modifier = caps;
      # bars = [ ];

      # fonts = {
      #   names = [ "Iosevka Nerd Font" ];
      #   style = "Bold";
      #   size = 11.0;
      # };

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

      # terminal = "${pkgs.kitty}/bin/kitty";
      # terminal = "/usr/bin/kitty";
      terminal = "kitty";

      keybindings = lib.mkOptionDefault {

        #"${caps}+Return" = "exec ${pkgs.kitty}/bin/kitty";
        "${caps}+Return" = "exec /usr/bin/kitty";
        #"${caps}+Return" = "kitty";
        "${win}+Return" = "exec /usr/bin/foot";

        # floating terminal (see float toggle in extraconfig)
        "${caps}+Shift+Return" = "exec --no-startup-id /usr/bin/kitty --class kitty-floating";

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

        "${win}+l" = "exec betterlockscreen --lock blur";

        "${caps}+c" = "exec firefox";

        "${caps}+m" = "exec pcmanfm -n";

        # "XF86AudioMute" = "exec amixer set Master toggle";
        # "XF86AudioLowerVolume" = "exec amixer set Master 4%-";
        # "XF86AudioRaiseVolume" = "exec amixer set Master 4%+";

        # https://github.com/i3/i3/issues/3343, for_window doesn't work for
        # containers, so the title format doesn't get applied.
        "${caps}+v" = "split v, focus parent, title_format \"█<span size='smaller'>  %title</span>\", focus child";

        "${caps}+d" = "exec ${pkgs.rofi}/bin/rofi -show run -config ~/.local/share/rofi/themes/squared-everforest.rasi";
        
        # TODO: there's still a white/blue styled selected option
        # TODO: this doesn't allow enter to accept entry
        "${alt}+Tab" = "exec ${pkgs.rofi}/bin/rofi -show window -kb-accept-entry '!Alt+Tab' -kb-element-next 'Alt+Tab' -config ~/.local/share/rofi/themes/squared-everforest.rasi"; #-kb-element-previous 'Alt+Shift+Tab'";

        
        "${caps}+0" = "workspace number 10";
        "${caps}+Shift+0" = "move container to workspace number 10";
      };

      # inside ~/.config/xkb/symbols/custom:
      # xkb_symbols "basic" {
      #   include "us"
      #   name[Group1]= "English (US Custom)";
      #   key <CAPS> { [ Hyper_L ] };
      #   modifier_map Mod5 { Hyper_L };
      #   modifier_map Mod4 { Super_L };
      # };
      input = {
        "*" = {
          xkb_layout = "custom";
          #xkb_options = "caps:hyper";
        };
      };

      output = {
        DP-5 = {
          mode = "2560x1440@99.946Hz";
          pos = "0 0";
        };
        DP-3 = {
          mode = "1920x1080";
          transform = "270";
          pos = "2560 0";
        };
        eDP-1 = {
          disable = "";
        };
      };
      
    };
    extraConfig = ''
      # floating kitty terminal (see floating terminal in keybinds)
      for_window [app_id="kitty-floating"] floating toggle
      
      # don't automatically focus the window the mouse is over
      focus_follows_mouse no
    '';
  };

  #programs.vscode = {
  #  enable = true;
  #  extensions = with pkgs.vscode-extensions; lib.mkForce [
  #    vscodevim.vim
  #  ];
  #};
}
