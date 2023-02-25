# amethyst, system configuration for BEAST HOME PC!

{ config, pkgs, hostname, lib, ... }:
let
  capsLockKBLayout = pkgs.writeText "xkb-layout" ''
    clear lock
    clear mod4
    clear mod5
    keycode 66 = Hyper_L
    !add lock = Hyper_L
    add mod4 = Super_L Super_R
    add mod5 = Hyper_L
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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

  # debug with `fc-list | grep 'fontname'`
  # https://nixos.wiki/wiki/Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    powerline-fonts
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
    # nerdfonts
  ];

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
    LEFT="DP-5"
    CENTER="DP-2"
    RIGHT="DP-1"
    HDMI="HDMI"
    
    # old 3 side by side normal orientations
    # ${pkgs.xorg.xrandr}/bin/xrandr \
    #   --output $LEFT --mode 1920x1080 --pos 0x10 --rotate normal \
    #   --output $RIGHT --mode 1920x1080 --pos 4480x10 --rotate normal \
    #   --output $CENTER --mode 2560x1440 --pos 1920x0 --rotate normal \
    #   --output $HDMI --off
      
    ${pkgs.xorg.xrandr}/bin/xrandr \
      --output $LEFT --mode 1920x1080 --pos 0x420 --rotate normal \
      --output $RIGHT --mode 1920x1080 --pos 4480x0 --rotate right \
      --output $CENTER --mode 2560x1440 --pos 1920x240 --rotate normal \
      --output $HDMI --off
    
    # set up my caps lock keyboard configuration
    #${pkgs.xorg.xmodmap}/bin/xmodmap ${capsLockKBLayout}
    ${pkgs.kbd-capslock}/bin/kbd-capslock

    # allow keyring authentication, apparently fails without this
    ${lib.getBin pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all
  '';

  services.udisks2.enable = true; # necessary for udiskie to work in home-manager (usb automounting)
  

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

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

  #programs.zsh.enable = true;

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
