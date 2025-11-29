# bench, workbench/radio laptop

{ config, pkgs, hostname, lib, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ../common/fonts
      ../common/pipewire
    ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;

    # efi = {
    #   canTouchEfiVariables = true;
    #   efiSysMountPoint = "/boot/efi";
    # };
    #
    # timeout = 2;

    # grub = {
    #   enable = true;
    #   devices = [ "nodev" ];
    #   efiSupport = true;
    #   useOSProber = false;
    # };
  };
  
  # Enable networking
  networking = {
    useDHCP = false; # networkmanager does this?
    networkmanager.enable = true;
    
    firewall = {
      enable = true; # default
      allowedTCPPorts = [ 22 ];
      allowedUDPPortRanges = [ ];
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
    desktopManager.session = [
      {
        name = "xsession";
        start = ''
          ${pkgs.runtimeShell} $HOME/.xsession &
          waitPID=$!
        '';
      }
    ];
	displayManager.lightdm.enable = true;

  };
  # services.displayManager = {
  #   sddm = {
  #     enable = true;
  #     theme = "${(pkgs.fetchFromGitHub {
  #       owner = "WildfireXIII";
  #       repo = "sddm-chili";
  #       rev = "caa55a0ed9996bcd3ddec2dd48a2c7975fa49f4c";
  #       sha256 = "09qd4fhbvj3afm9bmviilc7bk9yx7ij6mnl49ps4w5jm5fgmzxlx";
  #     })}";
  #   };
  # };

  programs.dconf.enable = true;
  
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

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  users.users.dwl = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  # NOTE: re-enabling this on 3/25/2023, I thought I disabled it because of
  # speed issues, but I get an error now when I compile my config otherwise.
  programs.zsh.enable = true;

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

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment.systemPackages = with pkgs; [
    kbd-capslock
  ];

  system.stateVersion = "25.05"; # Did you read the comment?

}
