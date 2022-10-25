# therock server system configuration

{ pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.editor = false; # prevents a root access trick
    loader.efi.canTouchEfiVariables = true;
    loader.efi.efiSysMountPoint = "/boot/efi";
    #kernelPackages = pkgs.linuxKernel.packages.linux_zen # TODO: use this for games
  };

  # networking
  networking = {
    useDHCP = false; # networkmanager does this?
    networkmanager.enable = true;
    
    firewall = {
      enable = true; # default
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  users.users.dwl = {
    isNormalUser = true;
    description = "Nathan";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
    ];

    # openssh.authorizedKeys.keys = []; # TODO: set this up
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    htop
    curl
    ncdu
    iproute2  # ip link etc.
  ];

  # sound
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

  # display
  services.xserver = {
    enable = true;
    layout = "us";
    
    # KDE/plasma
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };
  
  services.openssh = {
    enable = true;
    passwordAuthentication = true; # TODO: set this to false
    permitRootLogin = "no";
  };

  services.nextcloud = {
    enable = true;
    home = "/var/lib/nextcloud"; # default
  
    hostName = "localhost";
  
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = "/var/nextcloud-db-pass";
     
      adminpassFile = "/var/nextcloud-admin-pass";
      adminuser = "admin";
    };
  
    maxUploadSize = "10G";
  };
  
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };
  
  
  # ensure postgres is running before running the nextcloud setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };

  # security.acme = {
  #   acceptTerms = true;
  #   email = "nmblenderdude0@gmail.com";
  # };
  
  
  
  system.stateVersion = "22.05";
}
