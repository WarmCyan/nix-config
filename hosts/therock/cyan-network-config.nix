# external wireguard network container config

{ pkgs, lib, config, ... }:
let
  generator = import ./homepage_builder.nix { };
in
{

  networking.firewall.allowedTCPPorts = [ 
    80 
    8000
  ];

  networking.firewall.allowedUDPPorts = [ 51830 ];

  # networking.wireguard = {
  #   enable = true;
  #   interfaces = {
  #     # wg1 = {
  #     #   ips = [ "192.168.200.1/32" ];
  #     #
  #     #   listenPort = 51830;
  #     #
  #     #   privateKeyFile = "/etc/wg/private_key";
  #     #   generatePrivateKeyFile = true;
  #     # };
  #   };
  # };

  services.wg-access-server = {
    enable = true;
    settings = {
      https.enabled = false;
      dns.enabled = false;
      vpn.allowedIPs = [ "192.168.200.0/24" ];
      vpn.cidr = "192.168.200.0/24";
      wireguard.port = 51830;
      wireguard.interface = "wg2";
      port = 8000;
      loglevel = "debug";
      vpn.cidrv6 = 0;
      vpn.nat66 = false;
      externalHost = "192.168.1.31"; # eventually set to external ip
      httpHost = "192.168.200.1";
    };
    secretsFile = "/etc/wg/wg-access-server-secrets";
  };

  programs.tcpdump.enable = true;

  environment.systemPackages = with pkgs; [
    unixtools.net-tools
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
