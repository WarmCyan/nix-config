# The top level import module for all the home-manager configuration modules
# This file is where we deal with the "features" list that gets passed in.

{ inputs, lib, username, features, noNixos, configName, configLocation, pkgs, config, ... }:
let
  inherit (builtins) map pathExists filter;
in
{
  imports = [
    #./vscode-mutable.nix
    ./cli-core
  ]
  # import feature modules, features are passed by directory name 
  ++ filter pathExists (map (feature: ./${feature}) features);

  targets.genericLinux.enable = noNixos;
  programs.home-manager.enable = true;
  xdg.enable = true;

  xdg.dataFile."iris/configname".text = configName;
  xdg.dataFile."iris/configlocation".text = configLocation;

  # the power of modules!
  home = {
    inherit username;
    stateVersion = "22.05";
    homeDirectory = "/home/${username}";
    sessionVariables = {
      # https://github.com/nix-community/home-manager/pull/797
      TERMINFO_DIRS = "/usr/share/terminfo"; 
    };

    activation.report-changes = config.lib.dag.entryAnywhere /* bash */ ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
  };
}
