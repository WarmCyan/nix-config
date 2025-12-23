# external wireguard network container config

{ pkgs, lib, config, ... }:
# let
# in
{

  networking.firewall.allowedTCPPorts = [ 80 ];

  programs.tcpdump.enable = true;
  
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
