# therock, system configuration for homeserver

{ pkgs, lib, inputs, hostname, config, ... }:
let
  portGrafana       = 3000;
  portKiwix         = 4080;
  portWebDavNathan  = 7121;
  portWebDavMum     = 7122;
  portWebDavSis     = 7123;
  portWebDavShared  = 7124;
in
{
  imports = [
    ./hardware-configuration.nix
    ../common/pipewire
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
        portGrafana
        portKiwix
        portWebDavNathan
        portWebDavMum
        portWebDavSis
        portWebDavShared
        # 4080 # kiwix
        # 7121 # webdav: me
        # 7122 # webdav: mum
        # 7123 # webdav: sis
        # 7124 # webdav: shared
        # 3000 # grafana
        # 9001 # prometheus
        # 9002 # node exporter
      ];
    };
  };

  # https://discourse.nixos.org/t/cant-get-gnupg-to-work-no-pinentry/15373
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYSifrofamgq1lnJhhl8C6brPPjAlhzwL8IzKtl4j+1Gbtxd7G244r+seE/Qsp1PJ5uK1ocTK9hMNEMZW3gIkeuhHMBl1IN/ldZtP2OvBu3bVEaaJmpdWwu00+FtyAXHTjUX8YlEpbU1ZHlRi+8PzMbaqd5Y9oq+sjUhqd22Gkc6rKXX3hznkdW4FJZLbbfSg7jvijZZiGdm+IOiS6+UjXnZP0SsT9Xzjn5SXQNobWXU5CbNIJyH7ObD2rL9CWcfRzCQ6U7F43wWGEcwikGe6RPCxAjTlie4J8XI+NvcjUmhQ2WRFWrMLnF44EROnwtxpwugenlNq8lB/vPVdN/X5Wc9YZX7Z4CBXplxO/Uxgb3ZPdbaCpr7xlu9WXXq0FmdIA4c0oUDGRAcirYFzbXfOuix88qEg32I6bxyw+sx6m43NPL1TzrZEK/NN79jUErxzAh+SjH2y2T+5GZ1EFUrDSgXp1XaIuBdFjiMcLBEDOjZ1lFwtoAm7vIq7m/7X7GQc= dwl@delta"
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
    kiwix-tools

    pinentry-curses
  ];

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
        http_port = portGrafana;
        # domain = "therock.cyan.arpa";
        # root_url = "http://therock.cyan.arpa:3000/";
        domain = "192.168.1.3";
        root_url = "http://192.168.1.3:${toString portGrafana}/";
      };
    };
  };
  # make grafana available to phone through wg as well
  services.nginx = {
    enable = true;
    virtualHosts = {
      "grafana" = {
        listen = [{ port = portGrafana; addr="192.168.130.2"; }];
        locations."/" = {
          proxyPass = "http://192.168.1.3:${toString portGrafana}/";
          recommendedProxySettings = true;
        };
      };
      "service-index" = {
        listen = [{ port = 80; addr = "192.168.130.2"; }];
        locations."/" = {
          root = "/etc/web";
          tryFiles = "/index.html =404";
          # alias = "/etc/services_index.html";
        };
      };
    };
  };

  environment.etc = {
    "web/index.html".source = pkgs.writeText "index.html" /* html */ ''
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>DWLabs Wireguard Network</title>
        <style>
          body {
            background-color: black;
            color: white;
            font-family: arial;
          }
          a {
            color: #33AAFF;
          }
        </style>
      </head>
      <body>
        <h1>DWLabs Wireguard Network</h1>
        <p>Services server on wireguard network is at 192.168.130.2</p>
        <p><a href="http://192.168.130.2:${toString portKiwix}">Kiwix (${toString portKiwix})</a> - Local wikipedia/zim wikis</p>
        <p><a href="http://192.168.130.2:${toString portGrafana}">Grafana (${toString portGrafana})</a> - network/system monitoring</p>
        <p><a href="http://192.168.130.2:${toString portWebDavNathan}">Nathan's files (${toString portWebDavNathan})</a> - rclone webdav storage folder</p>
        <p><a href="http://192.168.130.2:${toString portWebDavSis}">Jackie's files (${toString portWebDavSis})</a> - rclone webdav storage folder</p>
        <p><a href="http://192.168.130.2:${toString portWebDavMum}">Mum's files (${toString portWebDavMum})</a> - rclone webdav storage folder</p>
        <p><a href="http://192.168.130.2:${toString portWebDavShared}">Shared files (${toString portWebDavShared})</a> - rclone webdav storage folder</p>
      </body>
    </html>
    '';
  };

  services.apcupsd.enable = true;

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        # enabledCollectors = [ "systemd" "zfs" "wireguard" "nut" "apcupsd" "processes" ];
        enabledCollectors = [ "systemd" "zfs" "processes" ];
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

  systemd.services.kiwix = {
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
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.kiwix-tools}/bin/kiwix-serve -i 192.168.130.2 -p ${toString portKiwix} /home/dwl/zim/*'";
    };
  };

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
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav --htpasswd /depository/htpasswd-nathan /depository/store --addr 192.168.130.2:${toString portWebDavNathan} --no-modtime --log-level INFO --vfs-cache-mode full --vfs-disk-space-total-size 2000G --vfs-used-is-size";
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
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav --htpasswd /depository/htpasswd-mum /depository/ext-webdav/karen --addr 192.168.130.2:${toString portWebDavMum} --no-modtime --log-level INFO";
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
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav --htpasswd /depository/htpasswd-jackie /depository/ext-webdav/jackie --addr 192.168.130.2:${toString portWebDavSis} --no-modtime --log-level INFO";
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
      ExecStart = "${pkgs.rclone}/bin/rclone serve webdav /depository/ext-webdav/shared --addr 192.168.130.2:${toString portWebDavShared} --no-modtime --log-level INFO";
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
