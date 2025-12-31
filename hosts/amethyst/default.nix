# amethyst, system configuration for BEAST HOME PC!

{ config, pkgs, hostname, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/fonts
      ../common/pipewire
      ../common/sddm.nix
    ];
  
  musnix.enable = true;


  # ==== FASTER TESTING THAN SERVER
  containers.cyan = {
    autoStart = true;
    privateUsers = "pick";
    config = (import ../therock/cyan-network-config.nix);
    privateNetwork = true;
    hostAddress = "192.168.1.31";  # firewall machine should point to this? "external" ip?
    localAddress = "192.168.1.30"; # address within the container?

    # TODO: just use enableTun?
    allowedDevices = [
      { modifier = "rwm"; node = "/dev/net/tun"; }
    ];

    forwardPorts = [
      { containerPort = 51830; hostPort = 51830; protocol = "udp"; }
    ];
  };
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve-cyan" ]; # I assume this should be wg1 too?
  networking.nat.externalInterface = "enp6s0";
  # ==== /FASTER TESTING THAN SERVER


  

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
      allowedUDPPortRanges = [
        { from = 34196; to = 34198; }  # factorio
      ];
    };
  };

  services.redshift = {
    enable = true;
    temperature.day = 6500;
    brightness.day = "1";
    temperature.night = 2000;
    brightness.night = "0.4";
    extraOptions = [
      "-v"
    ];
  };
  location.latitude = 35.964668;
  location.longitude = -83.926453;
  
  # services.small-git-server = {
  #   enable = true;
  #   userSSHKeys = {
  #     dwl = [
  #       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZsSBtvLAK8s2pIlKK7psGRvk+h1z3jJ7nCLPr18xK1Wu657H2AcNv7QF230lGabIKXRabiEHu2OhrSG02lu/KVpuOk4IudKRkE2UtOIMyt9+1eGj+1jzPHHxu2L7uLgySBLfN6e7WCObcUv15Mm5VYIYCs1hYNJopBnNa8pfBbhX0Hbhs0naJGB8XhF93PqZJTpTKv9YgPHgXGrB0a4ck8i249eCyx3i0FEO6IsymvvZVONcLo9hn3IHRVq8v3Tm8C0rbM7T5khFrXJ8/jhL198GA9YHglPDde6a7azmAAWd6JZZZpLwPQQQ8NvEjWNjlxss5Y2OmlbDLXDIsCwgG0iUNhJ9FJnqJrz0CVm+qrFv+xUflqP0vb/TJnx9iH0CS8/S4ftmwbVJK0cdmmTFTHRAtKb5OL87pKPbAhrWbLW9APaR7pyYwCFEho5W088Fwrt7GHn3D+jKukjXnFjiZWB2v8+qIQBmzdALmVcfPkPioVPuMBzNfimifpXIj/r0= dwl@amethyst"
  #     ];
  #   };
  #   cgit.enable = true;
  #   cgit.assets = ./cgit-assets;
  #   cgit.cssFiles = [ ./anothertest.css ];
  #   cgit.logo = ./cgit-assets/smiley.png;
  #   cgit.extraHeadInclude = ''
  #     <link rel="stylesheet" type="text/css" href="/git/assets/test.css" />
  #   '';
  #   cgit.css = ''
  #     td.sub {
  #       color: green !important;
  #     }
  #   '';
  #   cgitAttrName = "testingg";
  # };
  # services.cgit.testingg.nginx.location = "/git/";
  # services.nginx.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true; 
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/13
  services.xserver = {
    enable = true;
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
  # services.displayManager = {
  #   sddm = {
  #     enable = true;
  #     theme = "sddm-chili";
  #     # theme = "${(pkgs.fetchFromGitHub {
  #     #   owner = "WildfireXIII";
  #     #   repo = "sddm-chili";
  #     #   rev = "caa55a0ed9996bcd3ddec2dd48a2c7975fa49f4c";
  #     #   sha256 = "09qd4fhbvj3afm9bmviilc7bk9yx7ij6mnl49ps4w5jm5fgmzxlx";
  #     # })}";
  #   };
  # };
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # recommended from https://linuxhint.com/how-to-instal-steam-on-nixos/
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  # (see https://nixos.wiki/wiki/Nvidia)
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # https://discourse.nixos.org/t/xmodmap-keyboard-layout-customization-question/11522
  # https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/13
  # enable using the caps lock key has Mod5
  services.xserver.displayManager.sessionCommands = /* bash */''
    # set up the monitors
    LEFT="DP-1"
    CENTER="DP-4"
    RIGHT="DP-2"
    HDMI="HDMI"
    
    # old 3 side by side normal orientations
    # ${pkgs.xorg.xrandr}/bin/xrandr \
    #   --output $LEFT --mode 1920x1080 --pos 0x10 --rotate normal \
    #   --output $RIGHT --mode 1920x1080 --pos 4480x10 --rotate normal \
    #   --output $CENTER --mode 2560x1440 --pos 1920x0 --rotate normal \
    #   --output $HDMI --off
      
    # ${pkgs.xorg.xrandr}/bin/xrandr \
    #   --output $LEFT --mode 1920x1080 --pos 0x0 --rotate right \
    #   --output $RIGHT --mode 1920x1080 --pos 3640x0 --rotate left \
    #   --output $CENTER --mode 2560x1440 --pos 1080x334 --rotate normal --primary \
    #   --output $HDMI --off
    
    ${pkgs.xorg.xrandr}/bin/xrandr --output $HDMI --off --noprimary
    ${pkgs.xorg.xrandr}/bin/xrandr --output $LEFT --mode 1920x1080 --pos 0x0 --rotate right --noprimary
    ${pkgs.xorg.xrandr}/bin/xrandr --output $RIGHT --mode 1920x1080 --pos 3640x0 --rotate left --noprimary
    ${pkgs.xorg.xrandr}/bin/xrandr --output $CENTER --mode 2560x1440 --pos 1080x334 --rotate normal --primary

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
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.brlaser
  ];

  users.users.dwl = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      # (unstable.yabridge.override { wine = unstable.wineWowPackages.yabridge; })
      # (unstable.yabridgectl.override { wine = unstable.wineWowPackages.yabridge; })

      unstable.yabridge
      unstable.yabridgectl
      unstable.wineWowPackages.yabridge

      # wineWowPackages.full
      # wineWowPackages.waylandFull

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


  # enable docker
  virtualisation.docker.enable = true;
  
  
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
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  services.flatpak.enable = true; # enabling this solely for steam right now because of the glibc-eac bug https://github.com/ValveSoftware/Proton/issues/6051

  environment.systemPackages = with pkgs; [
    #xdg-desktop-portal-gtk
    
    openrgb
    i2c-tools

    # necessary for sddm theme
    # libsForQt5.qt5.qtquickcontrols
    # libsForQt5.qt5.qtgraphicaleffects

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


    # (fetchFromGitHub {
    #   owner = "WarmCyan";
    #   repo = "sddm-chili";
    #   rev = "caa55a0ed9996bcd3ddec2dd48a2c7975fa49f4c";
    #   sha256 = "09qd4fhbvj3afm9bmviilc7bk9yx7ij6mnl49ps4w5jm5fgmzxlx";
    # })

    unixtools.net-tools
    
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
