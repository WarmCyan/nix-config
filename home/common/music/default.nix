{ pkgs, lib, hostname, config, ... }:
{
  home.packages = with pkgs; [
    ario
    cantata
  ];
  
  programs.beets = {
    enable = true;
    settings = {
      directory = "~/music";
      plugins = [ "embedart" "fetchart" "edit" ];
      embedart = {
        auto = "yes";
      };
      fetchart = {
        auto = "yes";
      };
    };
  };
  
  programs.ncmpcpp.enable = true;
  
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/music";
  };
}
