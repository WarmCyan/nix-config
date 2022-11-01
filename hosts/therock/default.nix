# therock, system configuration for homeserver

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
    # https://unix.stackexchange.com/questions/378711/how-do-i-configure-postgress-authorization-settings-in-nixos
    authentication = lib.mkForce ''
      # Generated file; do not edit!
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
    '';
  };
  
  
  # ensure postgres is running before running the nextcloud setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };


  
  # let 
  #   backupScript = pkgs.writeTextFile {
  #     name = "nextcloud-backup-script";
  #     executable = true;
  #     destination = "/bin/nextcloud-backup.sh";
  #     text = /* bash */ ''
  #       mkdir -p "/storage/nextcloud-backup"
  #       sudo -u www-data php occ maintenance:mode --on
  #       rsync -Aavx /var/lib/nextcloud/ 
  #     '';
  #   };
  # in {
  # https://docs.nextcloud.com/server/latest/admin_manual/maintenance/backup.html
  systemd.services."nextcloud-backup" = {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ bash sudo rsync postgresql ];
    script = /* bash */ ''
      echo "Backing up nextcloud..."
      mkdir -p "/storage/nextcloud-backup"
      # NOTE: couldn't get it to find "occ"?
      #sudo -u nextcloud php occ maintenance:mode --on
      rsync -Aavx /var/lib/nextcloud/ /storage/nextcloud-backup/nextcloud-dirbkp_`date +"%Y-%m-%d"`/
      PGPASSWORD=$(cat "/var/nextcloud-db-pass") pg_dump "nextcloud" -h "localhost" -U "nextcloud" -f /storage/nextcloud-backup/nextcloud-sqlbkp_`date +"%Y-%m-%d"`.bak
      echo "Done!"
      #sudo -u nextcloud php occ maintenance:mode --off
    '';
  };
  # }

  systemd.timers."nextcloud-backup" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "nextcloud-backup.service" ];
    timerConfig = {
      Unit = "nextcloud-backup.service";
      OnCalendar = "Sun *-*-* 00:00:00"; # every sunday at midnight
    };
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
