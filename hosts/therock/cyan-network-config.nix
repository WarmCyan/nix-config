# external wireguard network container config

{ pkgs, lib, config, ... }:
let
  generator = import ./homepage_builder.nix { };
in
{


  # ==================================================
  # EMAIL
  # ==================================================
  users.users."vmail" = {
    createHome = true;
    home = "/var/spool/mail/vmail";
    uid = 994; # ...??? necessary?
  };
  users.groups."vmail" = {
    gid = 993; 
  };
  users.users."postfix" = {
    createHome = true;
    home = "/var/spool/postfix";
  };
  services.postfix = {
    enable = true;
    enableSubmission = true;
    enableSubmissions = true;

    settings.main = {
      # myhostname = "ip-192.168.200.1";
      # mydomain = "localhost";
      
      # NOTE: these work with cyan.arpa domains in all of the usernames
      # everywhere
      # myhostname = "cyan.arpa";
      # mydomain = "cyan";
      virtual_mailbox_domains = "cyan.arpa";

      # myhostname = "cyan.arpa";
      # mydomain = "cyan";
      # virtual_mailbox_domains = "192.168.200.1";
      
      virtual_uid_maps = "static:994";
      virtual_gid_maps = "static:993";
      # virtual_mailbox_domains = "192.168.200.1";
      # virtual_mailbox_domains = "[192.168.200.1]";
      virtual_mailbox_base = "/var/spool/mail/vmail";
      virtual_mailbox_maps = "hash:/etc/email/virtual_mailbox_maps";
      mailbox_transport = "lmtp:unix:/var/spool/postfix/dovecot-lmtp";
      virtual_transport = "lmtp:unix:/var/spool/postfix/dovecot-lmtp";

      # local_transport = "lmtp:unix:/var/spool/postfix/dovecot-lmtp";
      # local_recipient_maps = "hash:/etc/email/virtual_mailbox_maps";

      
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "/var/spool/postfix/auth";
      smtpd_sasl_auth_enable = "yes";
      smtpd_recipient_restrictions = "permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination";

      resolve_numeric_domain = "yes"; # allow ip addresses
    };

    # hostname = "ip-192.168.200.1";
    # domain = "192.168.200.1";

  };
  # https://wiki.nixos.org/wiki/Dovecot
  services.dovecot2 = {
    enable = true;
    enablePAM = false;
    # NOTE: password file most be mode 600 and owner/group dovecot2
    createMailUser = true;
    mailUser = "vmail";
    mailGroup = "vmail";
    mailLocation = "maildir:~/Maildir";
    mailboxes = {
      # use rfc standard https://apple.stackexchange.com/a/201346
      All = { auto = "create"; autoexpunge = null; specialUse = "All"; };
      Archive = { auto = "create"; autoexpunge = null; specialUse = "Archive"; };
      Drafts = { auto = "create"; autoexpunge = null; specialUse = "Drafts"; };
      Flagged = { auto = "create"; autoexpunge = null; specialUse = "Flagged"; };
      Junk = { auto = "create"; autoexpunge = "60d"; specialUse = "Junk"; };
      Sent = { auto = "create"; autoexpunge = null; specialUse = "Sent"; };
      Trash = { auto = "create"; autoexpunge = "60d"; specialUse = "Trash"; };
    };
      # auth_username_format = %Lu
    
        # (userdb) args = uid=vmail gid=vmail username_format=%u home=/var/spool/mail/vmail/%d/%n
    extraConfig = ''
      auth_default_realm = cyan.arpa
      auth_username_format = %n

      auth_mechanisms = plain
      passdb {
        driver = passwd-file
        args = /etc/email/dovecotusers
      }

      userdb {
        driver = static
        # the full e-mail address inside passwd-file is the username (%u)
        # user@example.com
        # %d for domain_name %n for user_name
        args = uid=vmail gid=vmail username_format=%n home=/var/spool/mail/vmail/%d/%n
      }

      # connection to postfix via lmtp
      service lmtp {
        unix_listener /var/spool/postfix/dovecot-lmtp {
          mode = 0600
          user = postfix
          group = postfix
        }
      }
      service auth {
        unix_listener /var/spool/postfix/auth {
          mode = 0600
          user = postfix
          group = postfix
        }
      }
    '';
    enableLmtp = true;
  };
  # ==================================================
  # /EMAIL
  # ==================================================


  

  networking.firewall.allowedTCPPorts = [ 
    80 # http
    
    25 # smtp
    465 # smtps

    # 993 # divecot imaps
    143 # dovecot imap
  ];

  networking.firewall.allowedUDPPorts = [ 51830 ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      wg2 = {
        ips = [ "192.168.200.1/32" ];
      
        listenPort = 51830;
      
        privateKeyFile = "/etc/wg/private_key";
        # generatePrivateKeyFile = true;
        peers = [
          {
            allowedIPs = [ "192.168.200.4/32" "192.168.130.3/32" ];
            publicKey = "6jHY+DAfq2xpKbsW4+H8FOX3z+MB9rZLvhiL24oJzgQ=";
          }
          {
            allowedIPs = [ "192.168.200.5/32" "192.168.130.8/32" ];
            publicKey = "Hwi4/lYNRUYbicDmbYXQZJ6md8YzGhedK7XkbxQwOQg=";
          }
          {
            allowedIPs = [ "192.168.200.2/32" ];
            # publicKey = "tlt353h0+X0wkCjnp2aDTK4dwvES3Iy60tjXfloQyVI=";
            publicKey = "/DcVm728bh5+7/EIdU2i+x0hwAE/iHcN9S3p35BgNDY=";
          }
        ];
      };
    };
  };

  # services.wg-access-server = {
  #   enable = true;
  #   settings = {
  #     https.enabled = false;
  #     dns.enabled = false;
  #     vpn.allowedIPs = [ "192.168.200.0/24" "192.168.130.3/32" "192.168.130.8/32" ];
  #     vpn.cidr = "192.168.200.0/24";
  #     wireguard.port = 51830;
  #     wireguard.interface = "wg2";
  #     port = 8000;
  #     loglevel = "debug";
  #     vpn.cidrv6 = 0;
  #     vpn.nat66 = false;
  #     externalHost = "192.168.1.31"; # eventually set to external ip
  #     httpHost = "192.168.200.1";
  #   };
  #   secretsFile = "/etc/wg/wg-access-server-secrets";
  # };
  #
  programs.tcpdump.enable = true;

  environment.systemPackages = with pkgs; [
    unixtools.net-tools
    wireguard-tools
    qrencode

    mailutils
  ];
  
  services.nginx = {
    enable = true;
    virtualHosts = {
      "services-index" = {
        # listen = [{ port = 80; addr = "192.168.1.30"; }]; # eventually should be wg ip
        # listen = [{ port = 80; addr = "192.168.1.30"; }]; # eventually should be wg ip
        listen = [{ port = 80; addr = "192.168.200.1"; }]; # eventually should be wg ip
        locations."/" = {
          root = "/etc/web";
          tryFiles = "/index.html =404";
        };
      };
    };
  };

  environment.etc = {
    "web/index.html".source = pkgs.writeText "index.html" (generator.generateHomepageHTML 
      {
        title = "Cyan Network";
        services = [
          {
            name = "CGit";
            port = 9000;
          }
          {
            name = "Testing";
            port = 8000;
            url = "what";
            icon = ''
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="34"
                height="34"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M12 12l0 .01" />
                <path d="M14.828 9.172a4 4 0 0 1 0 5.656" />
                <path d="M17.657 6.343a8 8 0 0 1 0 11.314" />
                <path d="M9.168 14.828a4 4 0 0 1 0 -5.656" />
                <path d="M6.337 17.657a8 8 0 0 1 0 -11.314" />
              </svg>
              '';
            desc = "This is a thing I do for testing";
          }
        ];
        defaultAddr = "http://192.168.200.1";
        css = /* css */ ''
          body {
            background-color: black;
            color: white;
            font-family: arial;
          }
          a {
            color: #77AAFF;
          }
        '';
      });
      
    # "web/index.html".source = pkgs.writeText "index.html" /* html */ ''
    #   <html>
    #     <body>
    #       <h1>Hello world!</h1>
    #     </body>
    #   </html>
    # '';
  };
}
