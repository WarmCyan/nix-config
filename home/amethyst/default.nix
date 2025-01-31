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

    ../common/music
  ];

  home.packages = with pkgs; [
    # -- audio --
    qpwgraph          # pipewire graphical controls (qjackctl but for pipewire)
    pavucontrol       # detailed audio settings
    easyeffects       # live audio effects
    audacity          # basic audio editing
    helvum            # another graphical tool for pipewire (seems worse than qpwgraph)
    mic-monitor       # custom tool to turn mic monitor on and off
    alsa-scarlett-gui # gui controls for focusrite 2i2 gen 3

    # -- monitoring tools --
    glances             # fancier htop
    nvtopPackages.full  # nvidia gpu monitoring
    #psensor             # CPU/GPU temp/activity monitoring (no longer maintained)
    dconf               # (this is required so psensor can save changes to theme (think it's a gtk thing))

    # -- creative --
    blender         # 3d animation, modeling, video editing
    gimp            # image editing
    inkscape        # SVG/illustrator tool
    obs-studio      # screen recording tool
    mixxx           # DJ software
    unstable.reaper # DAW
    lmms            # my older DAW :')
    bespokesynth    # experimental DAW
    surge-XT        # open source hybrid synthesizer
    sfizz           # soundfont sampler?
    carla           # windows vsts on linux
    yabridge        # windows vsts on linux
    yabridgectl

    # -- utils --
    flameshot         # screenshot tool
    pcmanfm           # file explorer
    feh               # image viewer/desktop wallpaper
    dunst             # notifications
    betterlockscreen  # super cool lock screen based on i3lock
    arandr            # multi-monitor configuration tool
    xclip             # clipboard tool
    asunder           # CD ripper
    vlc               # video/audio player
    wineWowPackages.unstableFull  # NOTE: necessary for several of the windows vst bridges
    ffmpeg            # video conversion/editing CLI
    imagemagick       # image conversion/editing CLI
    dnsutils          # includes nslookup
    usbutils          # includes lsusb
    wireguard-tools   # includes wg
    tcpdump           # watch/debug packets on network interfaces
    drawio            # diagramming tool

    # -- other --
    unstable.anki-bin   # spaced repetition software
    chromium            # for the times firefox doesn't cut it
    libreoffice-qt      # office suite
    calibre             # ebook library
    obsidian            # knowledge management
    python311           # a system (user) python so I can quickly run/test stuff

    # pulseaudio

    ranger
    st
    gcc


    # super experimental
    arcan
    # pipeworld
    # pipeworld-wrapped
    # durden
    # durden-wrapped

    pluto
  ];

  home.sessionVariables = {
    TERMINAL = "kitty";
    EDITOR = "nvim";
    #NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";
  };
  
  gtk = {
    enable = true;
    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      #package = pkgs.libsForQt5.qtstyleplugins;
      name = "adwaita-dark";
    };
  };

  # NOTE: that via the options listed in
  # https://rycee.gitlab.io/home-manager/options.html, we also have to enable
  # "services.udisks2.enable = true" in the system config for this to work on
  # NixOS
  # (usb automounting)
  services.udiskie = {
    enable=true;
  };


  # https://alexplescan.com/posts/2024/08/10/wezterm/
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    extraConfig = /* lua */''
    local config = wezterm.config_builder()

    config.font_size = 9.0
    config.font = wezterm.font({ family = "Droid Sans Mono Slashed for Powerline" })
    config.color_scheme = 'Gruvbox dark, hard (base16)'
    
    config.window_decorations = "RESIZE"
    -- https://wezfurlong.org/wezterm/config/appearance.html#dynamic-color-escape-sequences
    config.window_frame = {
      font_size=9.0,
      font = wezterm.font({ family="Iosevka Nerd Font" }),
      active_titlebar_bg = "#1177AA",
      inactive_titlebar_bg = "#353535",
    }

    config.use_fancy_tab_bar = True
    config.show_tabs_in_tab_bar = false
    config.show_new_tab_button_in_tab_bar = false


    config.window_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    }

    -- https://github.com/wez/wezterm/discussions/2537
    wezterm.on('window-focus-changed', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    if window:is_focused() then 
      overrides.window_frame = {
      font_size=9.0,
      font = wezterm.font({ family="Iosevka Nerd Font" }),
        active_titlebar_bg = "#1177AA",
        inactive_titlebar_bg = "#1177AA",
      }
    else 
      overrides.window_frame = {
      font_size=9.0,
      font = wezterm.font({ family="Iosevka Nerd Font" }),
        active_titlebar_bg = "#353535",
        inactive_titlebar_bg = "#353535",
      }
    end
    window:set_config_overrides(overrides)
    end)

    
    wezterm.on('update-status', function(window, pane)
      local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
      local color_scheme = window:effective_config().resolved_palette
      local bg = color_scheme.background
      local fg = color_scheme.foreground


      -- https://github.com/wez/wezterm/issues/1680#issuecomment-1058124061
      -- local actual_hostname = pane:get_user_vars().foo
      local actual_hostname = pane:get_user_vars().WEZTERM_HOST
      
      -- local actual_hostname2 = table.concat(pane:get_foreground_process_info().argv, " ")
      local actual_hostname2 = pane:get_foreground_process_info().argv[1]

      actual_hostname3 = wezterm.hostname()
      if pane:get_foreground_process_info().argv[1] == "ssh" then
        actual_hostname3 = pane:get_foreground_process_info().argv[2]
      end
      
      -- https://wezfurlong.org/wezterm/config/lua/window/set_right_status.html
      -- Figure out the cwd and host of the current pane.
      -- This will pick up the hostname for the remote host if your
      -- shell is using OSC 7 on the remote host.
      local cwd_uri = pane:get_current_working_dir()
      local cwd = ""
      local hostname = "NOOOOOOOOOO"
      if cwd_uri then
          cwd = cwd_uri.file_path
          hostname = cwd_uri.host --or wezterm.hostname()
      end

      window:set_right_status(wezterm.format({
        -- First, we draw the arrow...
        { Background = { Color = 'none' } },
        { Foreground = { Color = bg } },
        { Text = SOLID_LEFT_ARROW },
        -- Then we draw our text
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        -- { Text = ' ' .. wezterm.hostname() .. ' ' },
        { Text = ' ' .. actual_hostname3 .. ' ' },
      }))
    end)
    return config
    '';
    
  };

  programs.kitty = {
    # package = pkgs.stable.kitty;
    enable = true;
    themeFile = "GruvboxMaterialDarkHard";
    shellIntegration.mode = "disabled";
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
      cursor_shape = "block";
      cursor_blink_interval = "0";

      # improve input latency
      # https://beuke.org/terminal-latency/#fn:2
      repaint_delay = "8";
      input_delay = "0";
      sync_to_monitor = "no";
    };
  };

  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark-hard";
    location = "top-left";
    yoffset = 25;
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
  
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; lib.mkForce [
      vscodevim.vim
    ];
  };
}
