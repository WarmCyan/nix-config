# Main library of useful functions for the rest of the configuration
# Notably "mkHome" lives here!

{ inputs, ... }:
let
  inherit (inputs) self home-manager nixpkgs;
  inherit (nixpkgs.lib) systems genAttrs;
  inherit (self) outputs; # what is self? How are we getting outputs??? (oh, this is the self from the output parameters in flake.nix)
  inherit (home-manager.lib) homeManagerConfiguration;
in
rec {
  forAllSystems = genAttrs systems.flakeExposed;

  mkHome = {
    username,
    hostname ? null, # null seems bad
    system ? "x86_64-linux", # TODO: when actually move to nixos, switch to his default, it's better
    # colorscheme ? null, # nix-colors stuff
    wallpaper ? null,
    
    features ? [ ], # String names of directories in home/ with modules to include
    
    # whether to specify genericLinux target, set to true if not on nixOS, helps manage envvar things
    # https://nixos.wiki/wiki/Home_Manager#Usage_on_non-NixOS_Linux
    noNixos ? false, 
    
    gitUsername ? null, 
    gitEmail ? null,
  }:
    homeManagerConfiguration {
      pkgs = outputs.legacyPackages.${system};
      extraSpecialArgs = { # these are args that get passed to all modules
        inherit inputs, outputs, hostname, username, wallpaper, features,
        gitUsername, gitEmail, noNixos; # TODO: break into multiple lines? 
        # maybe a way to pass in an entire "configuration" like you would
        # normally that "updates" any stuff from the modules? I don't
        # understand how the order of this works.
      };
      modules = [ ../home ]; 
  };

  concatFiles = filesArray: builtins.concatStringsSep "\n" (builtins.map (x: builtins.readFile x) filesArray);
  concat = stringsArray: builtins.concatStringsSep "\n" stringsArray;
}
