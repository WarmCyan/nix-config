# The top level import module for all the home-manager configuration modules
# This file is where we deal with the "features" list that gets passed in.

{ inputs, lib, username, features, noNixos, ... }:

let
    inherit (builtins) map pathExists filter;
in
{
    imports = [
        ./cli-core
    ]
    # import feature modules, features are passed by directory name 
    ++ filter pathExists (map (feature: ./${feature}) features);

    targets.genericLinux.enable = noNixos;
    programs.home-manager.enable = true;

    # the power of modules!
    home = {
        inherit username;
        stateVersion = "22.05";
        homeDirectory = "/home/${username}";
        # TODO: don't we need to specify system?
    };
}
