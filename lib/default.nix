# Main library of useful functions for the rest of the configuration
# Notably "mkHome" lives here!

{ inputs, ... }:
let
  inherit (inputs) self home-manager nixpkgs-unstable nixpkgs;
  inherit (nixpkgs.lib) systems genAttrs;
  inherit (self) outputs pkgsFor; # what is self? How are we getting outputs??? (oh, this is the self from the output parameters in flake.nix)
  inherit (home-manager.lib) homeManagerConfiguration;
in
rec {
  # can be removed once I know forEachSystem works
  forAllSystems = genAttrs systems.flakeExposed;

  mkStableSystem = {
    configName,  # this should match the attribute name in the flake
    hostname,
    system,
    timezone ? "America/New_York",
    modules ? [ ../hosts ],
    configLocation ? "/home/dwl/lab/nix-config"
  }:
  builtins.trace "\nBuilding (STABLE) system configuration ${configName} for host ${hostname}...\nsystem: ${system}"
  nixpkgs.lib.nixosSystem {
    inherit system modules;
    # pkgs = outputs.legacyPackagesStable.${system};
    pkgs = pkgsFor.${system};
    specialArgs = { # these are args that get passed to all modules
      inherit self inputs outputs configName hostname timezone configLocation;
      stable = true;
    };
  };
  
  mkSystem = {
    configName,  # this should match the attribute name in the flake
    hostname,
    system,
    timezone ? "America/New_York",
    modules ? [ ../hosts ],
    configLocation ? "/home/dwl/lab/nix-config"
  }:
  builtins.trace "\nBuilding system configuration ${configName} for host ${hostname}...\nsystem: ${system}"
  nixpkgs-unstable.lib.nixosSystem {
    inherit system modules;
    #pkgs = outputs.legacyPackagesUnstable.${system};
    pkgs = pkgsFor.${system};
    specialArgs = { # these are args that get passed to all modules
      inherit self inputs outputs configName hostname timezone configLocation;
      stable = false;
    };
  };

  # TODO: switch to passing in modules here with a default to the config name,
  # same as systems above.
  mkHome = {
    configName,
    hostname ? null, # null seems bad
    username ? "dwl",
    system ? "x86_64-linux", # TODO: when actually move to nixos, switch to his default, it's better
    # colorscheme ? null, # nix-colors stuff
    wallpaper ? null,
    
    features ? [ ], # String names of directories in home/ with modules to include
    
    # whether to specify genericLinux target, set to true if not on nixOS, helps manage envvar things
    # https://nixos.wiki/wiki/Home_Manager#Usage_on_non-NixOS_Linux
    noNixos ? false, 
    
    gitUsername ? "Martindale, Nathan",  # TODO: there's probably a way via
    #overlays to make these "official options" without having to pass as
    #extraspecialargs (no actually, via modules on home-manager and calling
    #mkOption
    gitEmail ? "nathanamartindale@gmail.com",
    configLocation ? "/home/dwl/lab/nix-config",
    modules ? [ ../home ],
    pkgs
  }:
  builtins.trace "\nBuilding home for ${username}@${hostname}...\nsystem: ${system}"
  homeManagerConfiguration {
    #pkgs = outputs.legacyPackagesUnstable.${system};
    pkgs = pkgsFor.${system};
    inherit modules;
    extraSpecialArgs = { # these are args that get passed to all modules
      inherit self inputs outputs hostname username wallpaper features
        gitUsername gitEmail noNixos configLocation configName; 
      # maybe a way to pass in an entire "configuration" like you would
      # normally that "updates" any stuff from the modules? I don't
      # understand how the order of this works.
    };
  };

  concatFiles = filesArray: builtins.concatStringsSep "\n" (builtins.map (x: builtins.readFile x) filesArray);
  concat = stringsArray: builtins.concatStringsSep "\n" stringsArray;

}
