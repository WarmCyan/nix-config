# The top level import module for all the home-manager configuration modules
# This file is where we deal with the "features" list that gets passed in.

{ self, inputs, lib, username, features, noNixos, configName, configLocation, pkgs, config, ... }:
# let
#   inherit (builtins) map pathExists filter;
# in
let
  inherit (builtins) toString;
in
{
  imports = [
    #./vscode-mutable.nix
    #./cli-core
    ./${configName}
  ];
  # import feature modules, features are passed by directory name 
  #++ filter pathExists (map (feature: ./${feature}) features);
  
  home.packages = with pkgs; [
    iris
  ];

  targets.genericLinux.enable = noNixos;
  programs.home-manager.enable = true;
  xdg.enable = true;

  xdg.dataFile."iris/configname".text = configName;
  xdg.dataFile."iris/configlocation".text = configLocation;
  xdg.dataFile."iris/configRev".text = self.rev or "dirty";
  xdg.dataFile."iris/configShortRev".text = self.shortRev or "dirty";
  xdg.dataFile."iris/configRevCount".text = self.revCount or "dirty";
  xdg.dataFile."iris/configLastModified".text = if (self ? lastModified) then toString self.lastModified else "dirty";

  # the power of modules!
  home = {
    inherit username;
    stateVersion = "22.05";
    homeDirectory = "/home/${username}";
    sessionVariables = {
      # https://github.com/nix-community/home-manager/pull/797
      TERMINFO_DIRS = "/usr/share/terminfo"; 
    };
  };
}
