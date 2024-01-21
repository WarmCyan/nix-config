# amethyst, system configuration for BEAST HOME PC!

{ config, pkgs, hostname, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/fonts
      ../common/pipewire
    ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = false;

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    timeout = 2;

    grub = {
      enable = true;
      version = 2;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };
  
  # Enable networking
  networking = {
    useDHCP = false; # networkmanager does this?
    networkmanager.enable = true;
    
    hostName = hostname;
    
    firewall = {
      enable = true; # default
      allowedTCPPorts = [ 22 ];
    };
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true; 
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/13
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.theme = "${(pkgs.fetchFromGitHub {
      owner = "WildfireXIII";
      repo = "sddm-chili";
      rev = "caa55a0ed9996bcd3ddec2dd48a2c7975fa49f4c";
      sha256 = "09qd4fhbvj3afm9bmviilc7bk9yx7ij6mnl49ps4w5jm5fgmzxlx";
    })}";
    desktopManager.session = [
      {
        name = "xsession";
        start = ''
          ${pkgs.runtimeShell} $HOME/.xsession &
          waitPID=$!
        '';
      }
    ];
  };
  
  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true; # recommended from https://linuxhint.com/how-to-instal-steam-on-nixos/
  services.xserver.videoDrivers = [ "nvidia" ];

  # https://discourse.nixos.org/t/xmodmap-keyboard-layout-customization-question/11522
  # https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/13
  # enable using the caps lock key has Mod5
  services.xserver.displayManager.sessionCommands = /* bash */''
    # set up the monitors
    LEFT="DP-0"
    CENTER="DP-2"
    RIGHT="DP-5"
    HDMI="HDMI"
    
    # old 3 side by side normal orientations
    # ${pkgs.xorg.xrandr}/bin/xrandr \
    #   --output $LEFT --mode 1920x1080 --pos 0x10 --rotate normal \
    #   --output $RIGHT --mode 1920x1080 --pos 4480x10 --rotate normal \
    #   --output $CENTER --mode 2560x1440 --pos 1920x0 --rotate normal \
    #   --output $HDMI --off
      
    ${pkgs.xorg.xrandr}/bin/xrandr \
      --output $LEFT --mode 1920x1080 --pos 0x0 --rotate right \
      --output $RIGHT --mode 1920x1080 --pos 3640x0 --rotate left \
      --output $CENTER --mode 2560x1440 --pos 1080x334 --rotate normal \
      --output $HDMI --off
    
    # set up my caps lock keyboard configuration
    ${pkgs.kbd-capslock}/bin/kbd-capslock

    # allow keyring authentication, apparently fails without this
    ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all

    # give a decent theme in case I need to use xterm (modified variant of
    # kitty's 'gruvbox material dark hard')
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
      ! Black
      *color0: #151414
      *color8: #928374

      ! Red
      *color1: #ea6962
      *color9: #ea6962

      ! Green
      *color2:  #a9b665
      *color10: #a9b665

      ! Yellow
      *color3:  #e78a4e
      *color11: #d8a657

      ! Blue
      *color4:  #7daea3
      *color12: #7daea3

      ! Magenta
      *color5:  #d3869b
      *color13: #d3869b

      ! Cyan
      *color6:  #89b482
      *color14: #89b482

      ! White
      *color7:  #d4be98
      *color15: #d4be98

      *background: #1d2021
      *foreground: #d4be98
    EOF
  '';

  services.udisks2.enable = true; # necessary for udiskie to work in home-manager (usb automounting)
  # services.gvfs.enable = true;  # possibly necessary for cdroms?
  # services.devmon.enable = true;  # possibly necessary for cdroms?

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  users.users.dwl = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    ];
    shell = pkgs.zsh;
  };

  # NOTE: re-enabling this on 3/25/2023, I thought I disabled it because of
  # speed issues, but I get an error now when I compile my config otherwise.
  programs.zsh.enable = true;

  # https://linuxhint.com/how-to-instal-steam-on-nixos/
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.nix-ld.enable = true;
  
  
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true; # TODO: set this to false
      PermitRootLogin = "no";
    };
  };

  environment.variables = {
    #NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
    # the above does not work because it's accessing a restricted path (can't
    # access nix store directly) A workaround discussed in https://github.com/Mic92/nix-ld/pull/31
    #NIX_LD = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2";  # NOTE: this is what I had before update on 2022-12-26
    
    # NIX LD is a fancy dynamic linker so that packages that require a more FHS
    # like environment (micromamba!!) will still work. Note the
    # programs.nix-ld.enable above.
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  services.flatpak.enable = true; # enabling this solely for steam right now because of the glibc-eac bug https://github.com/ValveSoftware/Proton/issues/6051

  environment.systemPackages = with pkgs; [
    #xdg-desktop-portal-gtk
    
    openrgb
    i2c-tools

    # necessary for sddm theme
    libsForQt5.qt5.qtquickcontrols
    libsForQt5.qt5.qtgraphicaleffects

    kbd-capslock

    # steam stuff
    protonup-ng # so we can get the ge-proton version
    # NOTE: following https://github.com/cloudishBenne/protonup-ng,
    # I ran protonup -d "~/.steam/root/compatibilitytools.d/", and then
    # `protonup`
    steamcmd
    steam-run
    #steam-run-native # ???
    #(steam.override { extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ]; nativeOnly = true; }).run
    #(steam.override { withPrimus = true; extraPkgs = pkgs: [ bumblebee glxinfo ]; nativeOnly = true; }).run
    #(steam.override { withJava = true; })

    # experimental audio control
    #qpwgraph
    #pavucontrol
    # easyeffects # can't seem to get this to work, crashes when adding any
    # effect


    gparted
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
