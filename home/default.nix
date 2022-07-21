# The top level import module for all the home-manager configuration modules
# This file is where we deal with the "features" list that gets passed in.

{ inputs, lib, username, features, ... }:

let
    inherit (builtins) map pathExists filter;
in
{
    imports = [
        ./cli-core
    ]
    # import feature modules, features are passed by directory name 
    ++ filter pathExists (map (feature: ./${feature}) features);

    # targets.genericLinux.enable = true; # this shouldn't go here, this is
    # specific to non-nixOS. Where should we be doing this? TODO: Probably as a var in
    # mkHome.
    programs.home-manager.enable = true;

    # TODO: don't put this here, put this in cli-core, duh.
    programs.git = {
        enable = true;
        #userName  # TODO: these should get set from 
        #userEmail
        init = { defaultBranch = "main"; }; # seems to be the new standard
        core = { pager = "cat"; }; # less pager is annoying since output won't persist in console
        diff = { colorMoved = "zebra"; }; # differentiates edited code from code that was simply moved
        pull = { rebase = false; }; # default is to merge when pulling rather than rebase (potentially lose history and other's local branches will be out of whack)
        commit = { verbose = true; }; # show diff in commit editor
        color = { ui = "always"; };
    }

    # the power of modules!
    home = {
        inherit username;
        stateVersion = "22.05";
        homeDirectory = "/home/${username}";
        # TODO: don't we need to specify system?
    };
}
