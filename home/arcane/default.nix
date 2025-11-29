# arcane, home configuration for work linux workstation

{ pkgs, lib, nixgl, config, ... }:
let 
  #caps = "Mod5";
  caps = "Mod3";
  win = "Mod4";
  alt = "Mod1";

  colorActive = "F1B471";
  colorInactive = "343332";
  
  inherit (builtins) readFile;

  obsidian_wrapped = pkgs.writeShellScriptBin "obsidian-wrapped" ''
    XDG_CURRENT_DESKTOP=GNOME ${pkgs.unstable.obsidian}/bin/obsidian
  '';
in
{
  nixGL = {
    packages = nixgl.packages;
    defaultWrapper = "mesa";
  };
  
  imports = [
    ../common/cli-core
    ../common/dev
    ../common/vscode
    ../common/beta
    ../common/i3
    ../common/kitty
  ];

  programs.kitty = {
    package = (config.lib.nixGL.wrap pkgs.kitty);
    settings = {
      shell = "zsh";
    };
  };

  xdg = {
    desktopEntries = {
      pcmanfm = {
        name = "pcmanfm";
        exec = "${pkgs.pcmanfm}/bin/pcmanfm";
      };
      # https://forum.obsidian.md/t/open-in-default-app-blocks-obsidian-until-app-is-closed/80268/10
      obsidian = {
        name = "Obsidian";
        exec = "XDG_CURRENT_DESKTOP=GNOME ${pkgs.unstable.obsidian}/bin/obsidian %u";
      };
    };
    
    mimeApps.enable = true;
    mimeApps.defaultApplications = {
      "inode/directory" = [ "pcmanfm.desktop" ];
    };
  };

  desktop.i3 = {
    enable = true;
    colorActive = colorActive;
    colorInactive = colorInactive;
    browser = "firefox";
  };

  xsession = {
    profileExtra = /* bash */ ''
      eval `ssh-agent -s`
      export IAMPROFILE="hello"
      exec ${pkgs.kbd-capslock}/bin/kbd-capslock &
    '';

    windowManager.i3 = {
      package = (config.lib.nixGL.wrap pkgs.i3);

      config = rec {
        bars = [
          {
            position = "top";
            colors = {
              focusedWorkspace = {
                border = "#${colorActive}FF";
                background = "#${colorActive}FF";
                text = "#000000FF";
              };
            };
            statusCommand = "${pkgs.i3status}/bin/i3status -c /home/81n/i3status.conf";
          }
        ];
        
        #terminal = "${pkgs.kitty}/bin/kitty";
        keybindings = lib.mkOptionDefault {
          "${caps}+c" = lib.mkForce "exec firefox";

          "${caps}+slash" = "exec ${pkgs.zeal}/bin/zeal";
          "${win}+l" = "exec i3lock -i /home/81n/.lock-background-image.png";
        };
        startup = [
          {
            command = "${pkgs.kbd-capslock}/bin/kbd-capslock";
            always = true;
            notification = false;
          }
          {
            command = "${pkgs.kitty}/bin/kitty";
            always = true;
            notification = false;
          }
        ];
      };
      extraConfig = ''
        workspace 1 output DP-1
        workspace 2 output DP-2
      '';
    };
  };

  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
  };

  # programs.neovim = {
  #   # package = pkgs.stable.neovim;
  #
  #   extraPackages = lib.mkForce [ ];
  # };

  fonts.fontconfig.enable = true;
  
  home.packages = with pkgs; [
    zotero
    python311
    python311Packages.pip
    python311Packages.argcomplete

    ffmpeg
    inkscape

    asciinema
    asciinema-agg

    julia-bin

    xclip

    gifify

    mystmd
    unstable.obsidian
    obsidian_wrapped

    powerline-fonts
    # (nerdfonts.override { fonts = [ "Iosevka" "Inconsolata" ]; })
    nerd-fonts.iosevka
    nerd-fonts.inconsolata
    (config.lib.nixGL.wrap alacritty)


    cg
    tcg
    kbd-capslock
    tag

    pcmanfm
    lxappearance

    unstable.flameshot
  ];

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = { name = "adwaita-dark"; };
  };
  
  # still no luck :(
  # programs.librewolf = {
  #   # https://nixos.wiki/wiki/Librewolf
  #   enable = true;
  #   # package = pkgs.unstable.librewolf;
  #   policies = {
  #     DisableTelemetry = true;
  #     DisableFirefoxStudies = true;
  #     DisplayBookmarksToolbar = "never";
  #     Preferences = {
  #       "privacy.resistFingerprinting.letterboxing" = true;
  #       "browser.safebrowsing.downloads.enabled" = true;
  #       "browser.compactmode.show" = true;
  #       "cookiebanners.service.mode" = 2;
  #       "privacy.donottrackheader.enabled" = true;
  #     };
  #     ExtensionSettings = {
  #       # go to about:support to find extension IDs
  #       "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
  #         install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
  #         installation_mode = "force_installed";
  #       };
  #       "search@kagi.com" = {
  #         install_url = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
  #         installation_mode = "force_installed";
  #       };
  #       "addon@darkreader.org" = {
  #         install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
  #         installation_mode = "force_installed";
  #       };
  #     };
  #   };
  # };
  #

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; lib.mkForce [
      vscodevim.vim
    ];
  };

  programs.wezterm = {
    enable = true;
    package = (config.lib.nixGL.wrap pkgs.wezterm);
  };
}
