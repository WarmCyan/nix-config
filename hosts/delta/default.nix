# delta, system configuration for super awesome laptop!

{ config, pkgs, hostname, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../common/fonts
      ../common/pipewire
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 2;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # https://github.com/NixOS/nixpkgs/issues/106461 (will want to abstract some
  # of these into a module)
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];

  networking = {
    useDHCP = false; # I think networkmanager does this
    networkmanager.enable = true;
    hostName = hostname;

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    #synaptics.enable = true; # can't use both synaptics and libinput
    libinput = {
      enable = true;

      touchpad = {
        disableWhileTyping = true;
        additionalOptions = ''
          Option "PalmDetection" "on"
        '';
      };

    };
    #libinput.touchpad.naturalScrolling = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dwl = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [ "networkmanager" "wheel" "plugdev" ];  # plugdev for rtl-sdr
    packages = with pkgs; [
      firefox
      kate
    ];
    shell = pkgs.zsh;
  };
  users.groups.plugdev = {};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kbd-capslock
    # necessary for sddm theme
    libsForQt5.qt5.qtquickcontrols
    libsForQt5.qt5.qtgraphicaleffects
  ];
  
  programs.nix-ld.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/106461 rtlsdr
  services.udev.packages = [ pkgs.rtl-sdr ];
  
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true; # TODO: set this to false
      PermitRootLogin = "no";
    };
  };

  
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
  
  
  # enable using the caps lock key has Mod5
  services.xserver.displayManager.sessionCommands = /* bash */''
    # set up my caps lock keyboard configuration
    ${pkgs.kbd-capslock}/bin/kbd-capslock
  '';

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
  system.stateVersion = "22.11"; # Did you read the comment?

}
