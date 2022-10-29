# therock server system configuration

{ pkgs, lib, inputs, hostname, ... }: {
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
    unstable.htop  # just testing if this works...it does!!
    curl
    ncdu
    iproute2  # ip link etc.
    gnufdisk
    
    unstable.nix-output-monitor  # nix-output-monitor, maybe don't actually include this, just make it so my custom packages require it as a dependency.
    unstable.nvd
    
    iris
    #testing2
  ];

  # system.activationScripts.report-changes = /* bash */ ''
  #   PATH=$PATH:${lib.makeBinPath [ pkgs.unstable.nvd pkgs.nix ]}
  #   nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  # '';

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
    datadir = "/var/lib/nextcloud"; # default
  
    #hostName = "localhost";
    hostName = "localhost";
  
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = "/var/nextcloud-db-pass";
     
      adminpassFile = "/var/nextcloud-admin-pass";
      adminuser = "admin";

      extraTrustedDomains = [ "192.168.1.225" "therock" ];
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

  # NOTE: this doesn't work if I'm not using an actual domain name.
  # security.acme = {
  #   acceptTerms = true;
  #   email = "nmblenderdude0@gmail.com";
  # };
  # services.nginx = {
  #   enable = true;
  #   virtualHosts = {
  #     "192.168.1.225" = {
  #       forceSSL = true;
  #       enableACME = true;
  #     };
  #   };
  # };
  
  
  
  system.stateVersion = "22.05";
}
