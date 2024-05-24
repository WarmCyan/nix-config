# therock, system configuration for homeserver

{ pkgs, lib, inputs, hostname, config, ... }: {
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
    #networkmanager.enable = false;
    
    firewall = {
      enable = true; # default
      allowedTCPPorts = [ 
        22 
        80 
        443 
        7121 # webdav: me
        7122 # webdav: mum
        7123 # webdav: sis
        7124 # webdav: shared
        3000 # grafana
        #9001 # prometheus
        #9002 # node exporter
      ];
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

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxO5tXpnUz8q/HixsxjLatz9VnV3uBWvm9Qbk4QLjZA2mKmTYhMRK0iH6DNwLVDmorgZwr0tXzV6gLvnTf3uT2PAQQ34Mhoj57eAg3wAXSrEeM8fLuKXucMXKsoSBxNZMUVt+fVAmAG3pB3AhkeCw1yHTTe9Zj+rXEStr90ewc9g3InDF8PpcTmJzsFgdRb5aQxb9LR04+D6malNQSksIlcmxEDYvn/l2az+/+N1b+ymMF1rfi1ipU7e9oQiWwwlMtEROlhHhZxwbLycBhEqYZtbzaRSwUV1BFQ9WIp0xwW11Rq7nmpmeNJ3TA/tU53lz52VGDW7ItkB1WxDBtrYXyS0FpYWE7UXxB013IA04tf7yraitkh/wr9bqXfYpMyctdMc90Jo2E5Xaz6K7EajzeSwbk3jP7MPqH58XIqtLQRvjimfhVk63NFxCCemn8wjtCUjPUAFu3zNVN+5pgywnqYGBhY5pLAWixC2AhVDzYBmlqOH/v1w5OL2Y1phQLmyE= u0_a508@localhost"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZsSBtvLAK8s2pIlKK7psGRvk+h1z3jJ7nCLPr18xK1Wu657H2AcNv7QF230lGabIKXRabiEHu2OhrSG02lu/KVpuOk4IudKRkE2UtOIMyt9+1eGj+1jzPHHxu2L7uLgySBLfN6e7WCObcUv15Mm5VYIYCs1hYNJopBnNa8pfBbhX0Hbhs0naJGB8XhF93PqZJTpTKv9YgPHgXGrB0a4ck8i249eCyx3i0FEO6IsymvvZVONcLo9hn3IHRVq8v3Tm8C0rbM7T5khFrXJ8/jhL198GA9YHglPDde6a7azmAAWd6JZZZpLwPQQQ8NvEjWNjlxss5Y2OmlbDLXDIsCwgG0iUNhJ9FJnqJrz0CVm+qrFv+xUflqP0vb/TJnx9iH0CS8/S4ftmwbVJK0cdmmTFTHRAtKb5OL87pKPbAhrWbLW9APaR7pyYwCFEho5W088Fwrt7GHn3D+jKukjXnFjiZWB2v8+qIQBmzdALmVcfPkPioVPuMBzNfimifpXIj/r0= dwl@amethyst"
    ];
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
    tree
    lshw

    wireguard-tools
    apacheHttpd
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
    settings = {
      PasswordAuthentication = false; # TODO: set this to false
      PermitRootLogin = "no";
    };
  };


  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "192.168.1.225";
        http_port = 3000;
        domain = "therock.cyan.arpa";
        root_url = "http://therock.cyan.arpa:3000/";
      };
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "therock";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "firewall";
        static_configs = [{
          targets = [ "192.168.1.1:9100" ];
        }];
      }
    ];
  };


  # services.nextcloud = {
  #   enable = true;
  #   package = pkgs.nextcloud27;
  #   home = "/var/lib/nextcloud"; # default
  #   datadir = "/var/lib/nextcloud"; # default
  #
  #   #hostName = "localhost";
  #   hostName = "localhost";
  #
  #   config = {
  #     dbtype = "pgsql";
  #     dbuser = "nextcloud";
  #     dbhost = "/run/postgresql";
  #     dbname = "nextcloud";
  #     dbpassFile = "/var/nextcloud-db-pass";
  #   
  #     adminpassFile = "/var/nextcloud-admin-pass";
  #     adminuser = "admin";
  #
  #     extraTrustedDomains = [ "192.168.1.225" "therock" ];
  #   };
  #
  #   maxUploadSize = "10G";
  # };
  #
  #
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "nextcloud" ];
  #   ensureUsers = [
  #     {
  #       name = "nextcloud";
  #       ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
  #     }
  #   ];
  #   # https://unix.stackexchange.com/questions/378711/how-do-i-configure-postgress-authorization-settings-in-nixos
  #   authentication = lib.mkForce ''
  #     # Generated file; do not edit!
  #     # TYPE  DATABASE        USER            ADDRESS                 METHOD
  #     local   all             all                                     trust
  #     host    all             all             127.0.0.1/32            trust
  #     host    all             all             ::1/128                 trust
  #   '';
  # };
  #
  #
  #
  #
  # # ensure postgres is running before running the nextcloud setup
  # systemd.services."nextcloud-setup" = {
  #   requires = ["postgresql.service"];
  #   after = ["postgresql.service"];
  # };


  
  systemd.services.rclone-webdav-nathan = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      User = "dwl"; # change?
      Group = "users"; # change?
      Restart = "on-failure";
      RestartSec = "30s";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav --htpasswd /depository/htpasswd-nathan /depository/store --addr 192.168.130.2:7121 --no-modtime --log-level INFO --vfs-cache-mode full --vfs-disk-space-total-size 2000G --vfs-used-is-size";
    };
  };
  systemd.services.rclone-webdav-mum = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      User = "dwl"; # change?
      Group = "users"; # change?
      Restart = "on-failure";
      RestartSec = "30s";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav --htpasswd /depository/htpasswd-mum /depository/ext-webdav/karen --addr 192.168.130.2:7122 --no-modtime --log-level INFO";
    };
  };
  systemd.services.rclone-webdav-jackie = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      User = "dwl"; # change?
      Group = "users"; # change?
      Restart = "on-failure";
      RestartSec = "30s";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav --htpasswd /depository/htpasswd-jackie /depository/ext-webdav/jackie --addr 192.168.130.2:7123 --no-modtime --log-level INFO";
    };
  };
  systemd.services.rclone-webdav-shared = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      User = "dwl"; # change?
      Group = "users"; # change?
      Restart = "on-failure";
      RestartSec = "30s";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav /depository/ext-webdav/shared --addr 192.168.130.2:7124 --no-modtime --log-level INFO";
    };
  };


  # zfs backup stuff https://www.return12.net/zfs-on-nixos/
  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-1,15 02:30"; # 1st and 15th of every month
  };
  services.sanoid = {
    enable = true;
    templates.backup = {
      hourly = 36;
      daily = 30;
      monthly = 3;
      autoprune = true;
      autosnap = true;
    };

    datasets."depository/root" = {
      useTemplate = [ "backup" ];
    };
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
  # systemd.services."nextcloud-backup" = {
  #   serviceConfig.Type = "oneshot";
  #   path = with pkgs; [ bash sudo rsync postgresql ];
  #   script = /* bash */ ''
  #     echo "Backing up nextcloud..."
  #     mkdir -p "/storage/nextcloud-backup"
  #     # NOTE: couldn't get it to find "occ"?
  #     #sudo -u nextcloud php occ maintenance:mode --on
  #     rsync -Aavx /var/lib/nextcloud/ /storage/nextcloud-backup/nextcloud-dirbkp_`date +"%Y-%m-%d"`/
  #     PGPASSWORD=$(cat "/var/nextcloud-db-pass") pg_dump "nextcloud" -h "localhost" -U "nextcloud" -f /storage/nextcloud-backup/nextcloud-sqlbkp_`date +"%Y-%m-%d"`.bak
  #     echo "Done!"
  #     #sudo -u nextcloud php occ maintenance:mode --off
  #   '';
  # };
  # }

  # systemd.timers."nextcloud-backup" = {
  #   wantedBy = [ "timers.target" ];
  #   partOf = [ "nextcloud-backup.service" ];
  #   timerConfig = {
  #     Unit = "nextcloud-backup.service";
  #     OnCalendar = "Sun *-*-* 00:00:00"; # every sunday at midnight
  #   };
  # };
  #
  

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
