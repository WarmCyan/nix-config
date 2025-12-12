# therock, system configuration for homeserver

{ pkgs, lib, inputs, hostname, config, ... }:
let
  # portMiniflux      = 2000;
  # portFreshRSS      = 2025;
  portTTRSS         = 2030;
  portRSSBridge     = 2031;
  portImmich        = 2283;
  portGrafana       = 3000;
  portKiwix         = 4080;
  portEtherCalc     = 5032;
  portCGit          = 5080;
  portWebDavNathan  = 7121;
  portWebDavMum     = 7122;
  portWebDavSis     = 7123;
  portWebDavShared  = 7124;
  portInternalWC    = 8000;


  dwlKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxO5tXpnUz8q/HixsxjLatz9VnV3uBWvm9Qbk4QLjZA2mKmTYhMRK0iH6DNwLVDmorgZwr0tXzV6gLvnTf3uT2PAQQ34Mhoj57eAg3wAXSrEeM8fLuKXucMXKsoSBxNZMUVt+fVAmAG3pB3AhkeCw1yHTTe9Zj+rXEStr90ewc9g3InDF8PpcTmJzsFgdRb5aQxb9LR04+D6malNQSksIlcmxEDYvn/l2az+/+N1b+ymMF1rfi1ipU7e9oQiWwwlMtEROlhHhZxwbLycBhEqYZtbzaRSwUV1BFQ9WIp0xwW11Rq7nmpmeNJ3TA/tU53lz52VGDW7ItkB1WxDBtrYXyS0FpYWE7UXxB013IA04tf7yraitkh/wr9bqXfYpMyctdMc90Jo2E5Xaz6K7EajzeSwbk3jP7MPqH58XIqtLQRvjimfhVk63NFxCCemn8wjtCUjPUAFu3zNVN+5pgywnqYGBhY5pLAWixC2AhVDzYBmlqOH/v1w5OL2Y1phQLmyE= u0_a508@localhost"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZsSBtvLAK8s2pIlKK7psGRvk+h1z3jJ7nCLPr18xK1Wu657H2AcNv7QF230lGabIKXRabiEHu2OhrSG02lu/KVpuOk4IudKRkE2UtOIMyt9+1eGj+1jzPHHxu2L7uLgySBLfN6e7WCObcUv15Mm5VYIYCs1hYNJopBnNa8pfBbhX0Hbhs0naJGB8XhF93PqZJTpTKv9YgPHgXGrB0a4ck8i249eCyx3i0FEO6IsymvvZVONcLo9hn3IHRVq8v3Tm8C0rbM7T5khFrXJ8/jhL198GA9YHglPDde6a7azmAAWd6JZZZpLwPQQQ8NvEjWNjlxss5Y2OmlbDLXDIsCwgG0iUNhJ9FJnqJrz0CVm+qrFv+xUflqP0vb/TJnx9iH0CS8/S4ftmwbVJK0cdmmTFTHRAtKb5OL87pKPbAhrWbLW9APaR7pyYwCFEho5W088Fwrt7GHn3D+jKukjXnFjiZWB2v8+qIQBmzdALmVcfPkPioVPuMBzNfimifpXIj/r0= dwl@amethyst"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDYSifrofamgq1lnJhhl8C6brPPjAlhzwL8IzKtl4j+1Gbtxd7G244r+seE/Qsp1PJ5uK1ocTK9hMNEMZW3gIkeuhHMBl1IN/ldZtP2OvBu3bVEaaJmpdWwu00+FtyAXHTjUX8YlEpbU1ZHlRi+8PzMbaqd5Y9oq+sjUhqd22Gkc6rKXX3hznkdW4FJZLbbfSg7jvijZZiGdm+IOiS6+UjXnZP0SsT9Xzjn5SXQNobWXU5CbNIJyH7ObD2rL9CWcfRzCQ6U7F43wWGEcwikGe6RPCxAjTlie4J8XI+NvcjUmhQ2WRFWrMLnF44EROnwtxpwugenlNq8lB/vPVdN/X5Wc9YZX7Z4CBXplxO/Uxgb3ZPdbaCpr7xlu9WXXq0FmdIA4c0oUDGRAcirYFzbXfOuix88qEg32I6bxyw+sx6m43NPL1TzrZEK/NN79jUErxzAh+SjH2y2T+5GZ1EFUrDSgXp1XaIuBdFjiMcLBEDOjZ1lFwtoAm7vIq7m/7X7GQc= dwl@delta"
  ];
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

  
  # Enable CUPS to print documents.
  # NOTE: printer type is HL-L23800W
  services.printing = {
    enable = true;
    drivers = [
      pkgs.brlaser
    ];
    listenAddresses = [ "*:6031" ];
    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
    openFirewall = true;
  };

  # networking
  networking = {
    useDHCP = false; # networkmanager does this?
    networkmanager.enable = true;
    #networkmanager.enable = false;

    hosts = {
      "192.168.130.2" = [ "internal" ];
    };
    
    firewall = {
      enable = true; # default
      allowedTCPPorts = [ 
        22
        80
        443
        portGrafana
        portImmich
        portKiwix
        portEtherCalc
        portCGit
        portWebDavNathan
        portWebDavMum
        portWebDavSis
        portWebDavShared
        portInternalWC
        # portFreshRSS
        portTTRSS
        portRSSBridge
        # portMiniflux
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
    extraGroups = [ "nginx" "networkmanager" "wheel" "git" ];
    packages = with pkgs; [
      firefox
      kdePackages.kate
    ];

    openssh.authorizedKeys.keys = dwlKeys;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    unstable.htop  # just testing if this works...it does!!
    curl
    ncdu
    iproute2  # ip link etc.
    # gnufdisk
    
    unstable.nix-output-monitor  # nix-output-monitor, maybe don't actually include this, just make it so my custom packages require it as a dependency.
    unstable.nvd
    tree
    lshw

    wireguard-tools
    apacheHttpd
    usbutils
    kiwix-tools

    pinentry-curses
    pandoc
    python3

    uv
    imagemagick
  ];

  # display
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    
    # KDE/plasma
    # desktopManager.plasma5.enable = true;
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

  # services.miniflux = {
  #   enable = true;
  #   adminCredentialsFile = "/etc/miniflux.env";
  #   config = {
  #     LISTEN_ADDR = "192.168.130.2:${toString portMiniflux}";
  #     BASE_URL = "http://192.168.130.2:${toString portMiniflux}/";
  #     METRICS_ALLOWED_NETWORKS = "127.0.0.1/8,192.168.130.1/8";
  #     METRICS_COLLECTOR = "1";
  #   };
  # };
  #
  services.tt-rss-legacy = {
    enable = true;
    virtualHost = "ttrss";
    selfUrlPath = "http://192.168.130.2:${toString portTTRSS}";
    themePackages = [ inputs.tt-rss-nix.packages.x86_64-linux.tt-rss-plugin-theme-feedly-legacy ];
    pluginPackages = [
      # pkgs.tt-rss-plugin-feediron
      inputs.tt-rss-nix.packages.x86_64-linux.tt-rss-plugin-fresh-api-legacy
      inputs.tt-rss-nix.packages.x86_64-linux.tt-rss-plugin-close-btn-legacy
      # pkgs.tt-rss-plugin-close-button-legacy
    ];
    plugins = [
      "auth_internal"
      "note"
      "toggle_sidebar"
      "close_button"
    ];
  };

  services.rss-bridge = {
    enable = true;
    config = {
      system.enabled_bridges = [ 
        "XPathBridge" 
        "CssSelectorBridge"
        "CssSelectorComplexBridge"
        "CSSSelectorFeedExpander"
        "Filter"
        "FeedMerge"
        "FeedReducerBridge"
        "Reddit"
        "AssociatedPressNewsBridge"
        "ReutersBridge"
      ];
    };
  };

  services.small-git-server = {
    enable = true;
    userSSHKeys = {
      dwl = dwlKeys;
    };
    cgit.enable = true;
    cgit.cssFiles = [ ./cgit_gruvbox_theme.css ];
      cgit.css = /* css */ ''
        code div.highlight pre span.sd,
        code div.highlight pre span.s2,
        code div.highlight pre span.si {
          background-color: transparent;
        };
      '';
    cgitAttrName = "local-git";
  };
  services.cgit.local-git = {
    #nginx.location = "/git/";
    settings = {
      section-from-path = 3;
      # clone-url = "http://192.168.130.2:${toString portCGit}/$CGIT_REPO_URL git@192.168.130.2:${toString portCGit}/$CGIT_REPO_URL";
      clone-url = "git@192.168.130.2:$CGIT_REPO_URL";
    };
  };

  services.immich = {
    package = pkgs.unstable.immich;
    enable = true;
    port = portImmich;
    host = "192.168.1.3";
    machine-learning.enable = false;
    # database.enableVectors = false;
    # Note that /depository/immich had to be manually created and owner/group
    # both set to "immich"
    mediaLocation = "/depository/immich";
  };

  services.ethercalc = {
    enable = true;
    port = portEtherCalc;
  };

  # services.cryptpad = {
  #   enable = true;
  #   settings = {
  #     httpPort = portEtherCalc;
  #     httpAddress = "0.0.0.0";
  #     httpSafeOrigin = null;
  #   };
  # };
  
  #
  # services.freshrss = {
  #   enable = true;
  #   baseUrl = "http://192.168.130.2:${toString portFreshRSS}";
  #   # dataDir = "/depository/freshrss"
  #   passwordFile = "/run/secrets/freshrss";
  #   virtualHost = "freshrss";
  #   database = {
  #     type = "sqlite";
  #   };
  #   extensions = with pkgs.freshrss-extensions; [
  #     youtube
  #     title-wrap
  #   ];
  # };

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
      "local-git" = {
        listen = [{ port = portCGit; addr = "192.168.130.2"; }];
      };
      "ttrss" = {
        listen = [{ port = portTTRSS; addr="192.168.130.2"; }];

        # this is necessary for freshapi
        locations."~ /plugins\\.local/.*/api/.*\\.php(/|$)" = {
        extraConfig = ''
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          try_files $fastcgi_script_name =404;
          set $path_info $fastcgi_path_info;
          fastcgi_param PATH_INFO $path_info;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          fastcgi_pass unix:/run/phpfpm/tt-rss.sock;
          include ${config.services.nginx.package}/conf/fastcgi_params;
          fastcgi_index index.php;
          '';
       };
      };
      "rss-bridge" = {
        listen = [{ port = portRSSBridge; addr = "192.168.130.2"; }];
      };
      "immich" = {
        listen = [{ port = portImmich; addr = "192.168.130.2"; }];
        locations."/" = {
          # proxyPass = "http://[::1]:${toString config.services.immich.port}";
          proxyPass = "http://192.168.1.3:${toString portImmich}";
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            client_max_body_size 50000M;
            proxy_read_timeout   600s;
            proxy_send_timeout   600s;
            send_timeout         600s;
          '';
        };
      };
      # this is necessary because tt-rss won't download from non-80 ports. So,
      # added an address to /etc/hosts (networking.hosts) and proxy it here.
      # "rss-bridge-proxy" = {
        # listen = [{ port = 80; addr = "internal"; }];  # didn't work
        # listen = [{ port = 80; addr = "192.168.130.2"; }];
        # locations."/rss-bridge/" = {
        #   proxyPass = "http://192.168.130.2:${toString portRSSBridge}";
        #   recommendedProxySettings = true;
        # };
      # };
      # "freshrss" = {
      #   listen = [{ port = portFreshRSS; addr="192.168.130.2"; }];
      # };
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
        locations."/rss-bridge/" = {
          proxyPass = "http://192.168.130.2:${toString portRSSBridge}/";
          recommendedProxySettings = true;
        };
      };
      "internal-warmcyan" = {
        listen = [{ port = portInternalWC; addr = "192.168.130.2"; }];
        locations."/" = {
          root = "/www/html";
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
          a, h1 {
            /* color: #33AAFF; */
            color: #DD8855;
          }
        </style>
      </head>
      <body>
        <h1>Warm Network</h1>
        <p>Services on internal wireguard network at 192.168.130.2</p>
        <p><a href="http://192.168.130.2:${toString portTTRSS}">Tiny Tiny RSS (${toString portTTRSS})</a> - RSS/Feed reader</p>
        <!-- <p><a href="http://192.168.130.2:${toString portRSSBridge}">RSS Bridge (${toString portRSSBridge})</a> - RSS/Feed creator</p> -->
        <p><a href="http://192.168.130.2/rss-bridge">RSS Bridge (${toString portRSSBridge})</a> - RSS/Feed creator</p>
        <p><a href="http://192.168.130.2:${toString portImmich}">Immich (${toString portImmich})</a> - photo gallery</p>
        <p><a href="http://192.168.130.2:${toString portGrafana}">Grafana (${toString portGrafana})</a> - network/system monitoring</p>
        <p><a href="http://192.168.130.2:${toString portKiwix}">Kiwix (${toString portKiwix})</a> - local wikipedia/zim wikis</p>
        <p><a href="http://192.168.130.2:${toString portEtherCalc}">EtherCalc (${toString portEtherCalc})</a> - collaborative spreadsheets</p>
        <p><a href="http://192.168.130.2:${toString portCGit}">CGit (${toString portCGit})</a> - local git repo browser</p>
        <p><a href="http://192.168.130.2:${toString portWebDavNathan}">Nathan's files (${toString portWebDavNathan})</a> - rclone webdav storage folder</p>
        <p><a href="http://192.168.130.2:${toString portWebDavSis}">Jackie's files (${toString portWebDavSis})</a> - rclone webdav storage folder</p>
        <p><a href="http://192.168.130.2:${toString portWebDavMum}">Mum's files (${toString portWebDavMum})</a> - rclone webdav storage folder</p>
        <p><a href="http://192.168.130.2:${toString portWebDavShared}">Shared files (${toString portWebDavShared})</a> - rclone webdav storage folder</p>
        <p><a href="http://192.168.130.2:${toString portInternalWC}">Internal warmcyan.eco (${toString portInternalWC})</a> - local version of warmcyan.eco for testing</p>
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

      # nginx = {
      #   enable = true;
      #   port = 9008;
      #   listenAddress = "127.0.0.1";
      # };
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

  systemd.services."update-web-git-archive" = {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ bash git-bak ];
    script = /* bash */ ''
    echo "Beginning web git archive..."
    
    echo "Archiving work OSS..."
    git-bak -b /home/git/gitrepos/archive/github/work \
      https://github.com/ORNL/tx2.git \
      https://github.com/ORNL/curifactory.git \
      https://github.com/ORNL/ipyanchorviz.git \
      https://github.com/ORNL/icat.git \
      https://github.com/ORNL/ipyoverlay.git \
      https://github.com/ORNL/reno.git
    echo "Archived work OSS!"

    echo "Archiving personal repos..."
    # NOTE: in order for this to work, I add to copy dwl's id_rsa* into
    # /root/.ssh, and then add a set of lines in /root/.ssh/config:
    # https://stackoverflow.com/questions/4565700/how-to-specify-the-private-ssh-key-to-use-when-executing-shell-command-on-git
    if [[ -f "/root/githubtoken.txt" ]]; then
      echo "TOKEN FOUND."
      git-bak -b -u WarmCyan -t /root/githubtoken.txt /home/git/gitrepos/archive/github/WarmCyan
    else
      echo "TOKEN NOT FOUND."
      git-bak -b -u WarmCyan /home/git/gitrepos/archive/github/WarmCyan
    fi
    echo "Archived personal repos!"
    
    # git-bak 
    # rsync --archive --delete /home/git/* /depository/git_bak
    # chmod g+rw /depository/git_bak
    echo "Archive complete!"
    '';
  };
  systemd.timers."update-web-git-archive" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "update-web-git-archive.service" ];
    timerConfig = {
      Unit = "update-web-git-archive.service";
      OnCalendar = "*-*-* 00:00:00"; # daily at midnight
    };
  };


  systemd.services."local-git-backup" = {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ bash rsync ];
    script = /* bash */ ''
    echo "Beginning local git backup..."
    rsync --archive --delete /home/git/* /depository/git_bak
    # chmod g+rw /depository/git_bak
    echo "Backup complete!"
    '';
  };
  systemd.timers."local-git-backup" = {
    wantedBy = [ "timers.target" ];
    partOf = [ "local-git-backup.service" ];
    timerConfig = {
      Unit = "local-git-backup.service";
      OnCalendar = "*-*-* 01:00:00"; # daily at 1am
    };
  };

  systemd.services."depository-backup" = {
    serviceConfig.Type = "oneshot";
    path = with pkgs; [ bash sudo rsync mount umount ];
    script = /* bash */ ''
      echo "Begining depository backup..."
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
      OnCalendar = "*-*-* 02:00:00"; # daily at 2am
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
