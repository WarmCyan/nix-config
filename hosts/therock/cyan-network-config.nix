# external wireguard network container config

{ pkgs, lib, config, ... }:
# let
# in
{

  networking.firewall.allowedTCPPorts = [ 
    80 
    8000
  ];

  networking.firewall.allowedUDPPorts = [ 51830 ];

  networking.wireguard = {
    enable = true;
    interfaces = {
      # wg1 = {
      #   ips = [ "192.168.200.1/32" ];
      #
      #   listenPort = 51830;
      #
      #   privateKeyFile = "/etc/wg/private_key";
      #   generatePrivateKeyFile = true;
      # };
    };
  };

  services.wg-access-server = {
    enable = true;
    settings = {
      https.enabled = false;
      dns.enabled = false;
      vpn.allowedIPs = [ "192.168.200.1/24" ];
      vpn.cidr = "192.168.200.1/24";
      wireguard.port = 51830;
      wireguard.interface = "wg2";
      port = 8000;
      loglevel = "debug";
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
        listen = [{ port = 80; addr = "192.168.1.30"; }]; # eventually should be wg ip
        locations."/" = {
          root = "/etc/web";
          tryFiles = "/index.html =404";
        };
      };
    };
  };

  environment.etc = {
    "web/index.html".source = pkgs.writeText "index.html" /* html */ ''
      <html>
        <body>
          <h1>Hello world!</h1>
        </body>
      </html>
    '';
  };
}
