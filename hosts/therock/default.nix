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
    usbutils
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
    xkb = {
      layout = "us";
      variant = "";
    };
    
    # KDE/plasma
    desktopManager.plasma5.enable = true;
  };
  services.displayManager = {
    sddm.enable = true;
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
        http_addr = "192.168.1.3";
        http_port = 3000;
        # domain = "therock.cyan.arpa";
        # root_url = "http://therock.cyan.arpa:3000/";
        domain = "192.168.1.3";
        root_url = "http://192.168.1.3:3000/";
      };
    };
  };
  # make grafana available to phone through wg as well
  services.nginx = {
    enable = true;
    virtualHosts = {
      "grafana" = {
        listen = [{port = 3000; addr="192.168.130.2";}];
        locations."/" = {
          proxyPass = "http://192.168.1.3:3000/";
          recommendedProxySettings = true;
        };
      };
    };
  };

  # power.ups = {
  #   enable = true;
  #   mode = "netserver";
  #   ups = {
  #     usbups = {
  #       driver = "usbhid-ups";
  #       port = "auto";
  #       description = "USB UPS";
  #     };
  #   };
  # };
   # environment.etc = {
    #
    # "nut/upsd.conf".source = pkgs.writeText "upsd.conf"
    #   ''
    #     LISTEN 127.0.0.1 3493
    #   '';
    # "nut/upsd.users".source = pkgs.writeText "upsd.users"
    # ''
    #   [upsmon]
    #       password  = pass
    #       upsmon primary
    #       actions = set
    #       actions = fsd
    #       actions = test.panel.start
    #       instcmds = ALL
    # '';
    #
    # "nut/upsmon.conf".source = pkgs.writeText "upsmon.conf"
    #   ''
    #     MONITOR usbups@localhost 1 upsmon pass primary
    #     MINSUPPLIES 1
    #     SHUTDOWNCMD "${pkgs.systemd}/bin/systemctl poweroff"
    #     POLLFREQ 5
    #     POLLFREQALERT 5
    #     HOSTSYNC 15
    #     DEADTIME 15
    #     POWERDOWNFLAG /etc/killpower
    #     RBWARNTIME 43200
    #     NOCOMMWARNTIME 300
    #     FINALDELAY 5
    #   '';
    #
    # };

  services.apcupsd.enable = true;

  
  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "zfs" "wireguard" "nut" "apcupsd" "processes" ];
        # extraFlags = [
        #   "--collector.textfile.directory"
        # ];
        port = 9002;
        listenAddress = "127.0.0.1";
      };
      
      wireguard = {
        enable = true;
        port = 9003;
        listenAddress = "127.0.0.1";
      };
      
      zfs = {
        enable = true;
        port = 9004;
        listenAddress = "127.0.0.1";
      };
      
      apcupsd = {
        enable = true;
        port = 9005;
        listenAddress = "127.0.0.1";
      };

      nut = {
        enable = true;
        port = 9006;
        listenAddress = "127.0.0.1";
        nutServer = "127.0.0.1";
      };
      
      systemd = {
        enable = true;
        port = 9007;
        listenAddress = "127.0.0.1";
      };
    };

    scrapeConfigs = [
      # {
      #   job_name = "nut";
      #   metrics_path = "/ups_metrics";
      #   params = {
      #     ups = [ "usbups" ];
      #   };
      #   static_configs = [{
      #     targets = [
      #       "127.0.0.1:${toString config.services.prometheus.exporters.nut.port}"
      #     ];
      #     labels = {
      #       ups = "usbups";
      #     };
      #   }];
      # }
      {
        job_name = "apc";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.apcupsd.port}" ];
        }];
      }
      {
        job_name = "systemd";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}" ];
        }];
      }
      {
        job_name = "wireguard";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.wireguard.port}" ];
        }];
      }
      {
        job_name = "zfs";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.zfs.port}" ];
        }];
      }
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

  # services.syncoid = {
  #   enable = true;
  #   interval = "hourly";
  #   localTargetAllow = [ "change-key" "compression" "create" "mountpoint" "receive" "rollback" "mount" "destroy" "release" "hold" ];
  #   localSourceAllow = [ "bookmark" "hold" "send" "snapshot" "destroy" "mount" "release" ];
  #   commonArgs = [ "--no-sync-snap" "--use-hold" ]; # "--force-delete" ];
  #   commands."depository-hot-swap-a" = {
  #     source = "depository/root";
  #     target = "backup_depository_A/root";
  #   };
  #   commands."depository-hot-swap-b" = {
  #     source = "depository/root";
  #     target = "backup_depository_B/root";
  #   };
  # };
  
  # networking.interfaces.enp3s0.ipv4.routes = [{
  #   address = "192.168.130.3";
  #   prefixLength = 32;
  #   via = "192.168.130.1";
  # }];
  
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


  systemd.services."depository-backup" = {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ bash sudo rsync mount umount ];
    script = /* bash */ ''
      echo "Begining backup..."
      sudo mount ID=usb-USB_3.0_HDD_Docking_Station_201710310028-0:0-part1 /backup_depository/
      rsync --archive --delete /depository /backup_depository
      sudo umount /backup_depository
      echo "Backup complete!"
    '';
  };
  systemd.timers."depository-backup" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "depository-backup.service" ];
    timerConfig = {
      Unit = "depository-backup.service";
      OnCalendar = "*-*-* 00:00:00"; # daily
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
