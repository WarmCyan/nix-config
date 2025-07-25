# (2022/07/20) Recreating this flake based on misterio's as it has many of the
# elements I'm looking for: https://github.com/Misterio77/nix-config
# TODO: he has a bunch of cool looking nix tools listed:
# https://github.com/Misterio77/nix-config/blob/main/home/misterio/cli/default.nix
#
# (2022/07/21) NOTE: we can have each home-manager config have its own dedicated
# folder in home too, if we want to specify individual machine stuff without
# trying to figure out how to do a ton of abstraction

# (2022/07/22) Is it possibly worth it to extract a lot of the vim config stuff 
# into development modules? It would be nice if cli-core were actually pretty small,
# and maybe there are quite a few systems where I don't really need any language 
# servers.
# TODO: also have a "minimal" hm that has almost nothing
# Note that the way you update packages (I think) for a home mangaer configuration
# is as they mention in their wiki, which is literally just "nix flake update":
# https://rycee.gitlab.io/home-manager/index.html#sec-flakes-standalone
# Also see the third-deep nested comment, discusses how you can explicitly set nix 
# to directly follow a specific url
# https://www.reddit.com/r/NixOS/comments/pmz2vi/how_do_i_update_nix_to_the_latest_unstable_version/

# (2022/07/24) Current problem with bootstrap: the first time you run it never
# works because I guess nix isn't found in path yet?

# (2022/09/14) I added a basic vscode install to arcane, but there's a lot of
# features that don't work since you can't edit the settings on the fly. There's
# a solution to this that modifies home activation for that package, seems
# fairly straightfoward: https://github.com/nix-community/home-manager/issues/1800

# (2022/10/23) I regularly get a "tput: unknown terminal 'xterm-kitty'" error the 
# time I'm trying to install things. This might be related to 
# https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-when-sshing-into-a-different-computer
# where the solution is to ssh with `kitty +kitten ssh myserver` It might be worth
# it to eventually include that terminfo directly in my config and copy over?


# (2022/10/26) Another valuable set of dotfiles to reference: https://man.sr.ht/~hutzdog/dotfiles/



# the nixos/flake book, potentially some good conventions to use here:
# https://nixos-and-flakes.thiscute.world/nixos-with-flakes/downgrade-or-upgrade-packages

# TODO's
# ===============================
# TODO: make each profile use separate lock file through iris
# TODO: add iris flag to pass next flags to underlying commands
# TODO: make opengl stuff work on non-nixos: https://github.com/nix-community/nixGL/issues/114#issuecomment-1585323281

# TODO: make an install nix anywhere script https://zameermanji.com/blog/2023/3/26/using-nix-without-root/ 
#   curl -L https://hydra.nixos.org/job/nix/maintenance-2.20/buildStatic.x86_64-linux/latest/download-by-type/file/binary-dist > nix
#   export NIX_CONF_DIR="[...]/.config/nix"
#   (set up the nix.conf)
#   ./nix ... (will use .local/share/nix)
# (for it to work on macos will likely need https://github.com/nixie-dev/fakedir)

#   nix shell nixpkgs#homemanager

#
# 
# STRT: make the cli-core nvim more minimal, use dev modules to add more plugin stuff
# TODO: way to automate firefox speedups? https://www.drivereasy.com/knowledge/speed-up-firefox/ (will need to add nur which has firefox and extensions)
# TODO: script to keep backup ref to home-manager gen and make it easy to switch to that one
# TODO: add pre-commit stuff to this
# TODO: snippet for nix header block
# TODO: fix vim auto line break to be how I used to have it
# TODO: investigate allowing serving a nix store via ssh https://nixos.org/manual/nix/stable/package-management/ssh-substituter.html
# TODO: make some nice plymouth boot stuff! 

# MODULES NEEDED
#================================
# dev (-python -web -research) [unclear how much to break this up]
# research
# desktop/i3
# radio
# (hosting stuff)
# gaming

# Debugging tools:
#-------------------
# builtins.trace e1 e2 (prints e1, returns e2)
# nixpkgs.lib.traceVal e1 (prints and returns e1)

# QUESTIONS
# ===============================
#   - He has custom pkgs, but how does he reference them/pull them in?
#   A: ahhh, I believe he does it in overlay/default.nix at the end, the // ../pkgs
#
#   - Where does he pull in the features? lib.mkHome only puts them into
#   "extraSpecialArgs" along with some modules.
#   A: Inside home/misterio/default, he has an imports list that concats a map
#   with the features list (this "imports" is what makes it a "module", and it
#   is notably importing other modules)
#
#   - How do modules work, do they just automagically append everything when
#   multiple modules are all assigning to the same thing?
#   A: Yeah I think so, in https://nixos.wiki/wiki/Module in "under the hood",
#   they mention that for each option they collect all definitions from all
#   modules and merge them together according to options type.
#   NOTE: so this means we could probably have things like vim plugins/settings
#   modularized too? (e.g. I don't want javascript linters clogging up my system
#   if I have no intention of developing javascript on that system.)
#   NOTE: also, I can probably nest folders like misterio but also have default
#   in top level, so you can either auto import everything by specifying the top
#   level feature, or specify only select things.
#
#   - Wait, where's the "laptop" module? He mentions in /home/misterio/default
#   "import features _that have modules_, are there features that don't?
#
#   - How do we get those other elements put into extraSpecialArgs? 
#   A: They are passed as arguments to each module, so the beginning { ... }
#   function def line.
#
#   - How do I get access to my library functions deep within modules?
#   A: It's somehow still an argument being passed around.

{
  description = "My awesome-sauce and cool-beans nix configuration-y things.";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    
    # keeping around so if I ever need a specific nixpkgs commit, use this
    # nixpkgs-pinned.url = "github:nixos/nixpkgs?rev=988cc958c57ce4350ec248d2d53087777f9e1949";

    home-manager = {
      # https://github.com/EmergentMind/nix-config
      # TODO TODO: TODO: TODO: https://discourse.nixos.org/t/anatomy-of-a-nixos-config/40252
      # TODO: apparently you can follow specific releases? (e.g.
      # home-manager/release-23.11) would this solve some of the stability
      # issues?
      # TODO: is there a way to see a list of changes to options in HM modules
      # that I use?
      # TODO: look into using nixvim instead of doing neovim through HM
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # unsure what this actually does. (It
      # makes it so that home-manager isn't downloading it's own set of nixpkgs,
      # we're "overriding" the nixpkgs input home-manager defines by default)
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-git-server = {
      url = "github:WarmCyan/simple-git-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: add in nix-colors! 
  };

  #outputs = inputs:
  outputs = { self, nixpkgs, home-manager, nixgl, simple-git-server, ... } @ inputs:
  let
    inherit (self) outputs;
    
    systems = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
    forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (system: import nixpkgs {
      inherit system;
      overlays = builtins.attrValues outputs.overlays ++ [ 
          nixgl.overlay 
          # simple-git-server.overlays.default 
        ];
      config.allowUnfree = true;
    });
  
    mylib = import ./lib { inherit inputs; };
    lib = nixpkgs.lib // home-manager.lib // mylib;
    
    inherit (mylib) mkHome mkSystem mkStableSystem forAllSystems;
    inherit (builtins) attrValues;
  in
  {
    inherit mylib;
    inherit lib;
    inherit pkgsFor;

    overlays = import ./overlays { inherit inputs outputs; };

    # =================== NIXOS CONFIGURATIONS ==================

    nixosConfigurations = {
      delta = lib.nixosSystem {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./hosts ];
        specialArgs = {
          inherit self inputs outputs;
          stable = true;
          configName = "delta";
          hostname = "delta";
          configLocation = "/home/dwl/lab/nix-config";
          timezone = "America/New_York";
        };
      };
      # delta = mkSystem {
      #   configName = "delta";
      #   hostname = "delta";
      #   system = "x86_64-linux";
      # };  
      # amethyst = mkSystem {
      #   configName = "amethyst";
      #   hostname = "amethyst";
      #   system = "x86_64-linux";
      # };  
      amethyst = lib.nixosSystem {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./hosts simple-git-server.nixosModules.git-server ];
        specialArgs = {
          inherit self inputs outputs;
          stable = true;
          configName = "amethyst";
          hostname = "amethyst";
          configLocation = "/home/dwl/lab/nix-config";
          timezone = "America/New_York";
        };
      };
      therock = lib.nixosSystem {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./hosts ];
        specialArgs = {
          inherit self inputs outputs;
          stable = true;
          configName = "therock";
          hostname = "therock";
          configLocation = "/home/dwl/lab/nix-config";
          timezone = "America/New_York";
        };
      };
    };

    # ===========================================================



    # =================== HOME CONFIGURATIONS ===================
      
    homeConfigurations = {
      # primary desktop
      phantom = mkHome {
        configName = "phantom";
        username = "dwl";
        hostname = "phantom";
        noNixos = true;
      };
      # amethyst = mkHome {
      #   configName = "amethyst";
      #   username = "dwl";
      #   hostname = "amethyst";
      # };
      amethyst = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./home ];
        extraSpecialArgs = {
          inherit self inputs outputs;
          hostname = "amethyst";
          username = "dwl";
          configName = "amethyst";
          gitUsername = "Martindale, Nathan";
          gitEmail = "nathanamartindale@gmail.com";
          configLocation = "/home/dwl/lab/nix-config";
          noNixos = false;
        };
      };
	
      # primary laptop
      delta = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./home ];
        extraSpecialArgs = {
          inherit self inputs outputs;
          hostname = "delta";
          username = "dwl";
          configName = "delta";
          configLocation = "/home/dwl/lab/nix-config";
          gitUsername = "Martindale, Nathan";
          gitEmail = "nathanamartindale@gmail.com";
          noNixos = false;
        };
      };
      # delta = mkHome {
      #   configName = "delta";
      #   username = "dwl";
      #   hostname = "delta";
      # };

      # homeserver
      therock = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./home ];
        extraSpecialArgs = {
          inherit self inputs outputs;
          hostname = "therock";
          username = "dwl";
          configName = "therock";
          gitUsername = "Martindale, Nathan";
          gitEmail = "nathanamartindale@gmail.com";
          configLocation = "/home/dwl/lab/nix-config";
          noNixos = false;
        };
      };

      # work linux workstation 
      arcane = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./home ];
        extraSpecialArgs = {
          inherit self inputs outputs nixgl;
          hostname = "arcane";
          username = "81n";
          configName = "arcane";
          configLocation = "/home/81n/lab/nix-config";
          gitEmail = "martindalena@ornl.gov";
          gitUsername = "Martindale, Nathan";
          noNixos = true;
        };
      };

      # work linux laptop 
      planet = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./home ];
        extraSpecialArgs = {
          inherit self inputs outputs nixgl;
          hostname = "planet";
          username = "81n";
          configName = "planet";
          configLocation = "/home/81n/lab/nix-config";
          gitUsername = "Martindale, Nathan";
          gitEmail = "martindalena@ornl.gov";
          noNixos = true;
        };
      };

      # work cluster
      endor = lib.homeManagerConfiguration {
        pkgs = pkgsFor.x86_64-linux;
        modules = [ ./home ];
        extraSpecialArgs = {
          inherit self inputs outputs;
          hostname = "endor";
          username = "81n";
          configName = "endor";
          configLocation = "/data/jocasta/home/81n";
          gitUsername = "Martindale, Nathan";
          gitEmail = "martindalena@ornl.gov";
          noNixos = true;
        };
      };

      # work laptop (wsl)
      wlap = mkHome {
        configName = "wlap";
        username = "dwl";
        hostname = "LAP124750";

        features = [ "dev" ];
        noNixos = true;
        gitEmail = "martindalena@ornl.gov";
      };

      # work laptop (mac)
      wmac = mkHome {
        configName = "wmac";
        username = "81n";
        hostname = "MAC135974";
        system = "aarch64-darwin";
        #noNixos = true;
        gitEmail = "martindalena@ornl.gov";
        configLocation = "/Users/81n/lab/nix-config";
      };
    };
    
    # ===========================================================
	
    # overlays = {
    #   # https://nixos.wiki/wiki/Flakes (see section "Importing packages from multiple channels")
    #   # a single overlay that always includes both,
    #   # this would allow modules that get imported from both a stable and 
    #   # unstable context to work if they require a specific channel, and all the
    #   # rest of the packages will just default to whatever context called from.
    #  
    #   stable-unstable-combo = final: prev: {
    #     unstable = import inputs.nixpkgs-unstable {
    #       system = prev.system;
    #       config.allowUnfree = true;
    #       config.permittedInsecurePackages = [ "electron-25.9.0" ];
    #     };
    #     stable = import inputs.nixpkgs {
    #       system = prev.system;
    #       config.allowUnfree = true;
    #     };
    #   };
    #  
    #   custom-pkgs = import ./overlay { inherit inputs; };
    # };

    # overlay-unstable = final: prev: {
    #   unstable = import inputs.nixpkgs-unstable {
    #     system = prev.system;
    #     config.allowUnfree = true;
    #   };
    # };
    #
    # overlay-stable = final: prev: {
    #   stable = import inputs.nixpkgs-stable {
    #     system = prev.system;
    #     config.allowUnree = true;
    #   };
    # };

    # legacyPackagesUnstable = forAllSystems (system:
    #   import inputs.nixpkgs-unstable {
    #     inherit system;
    #     overlays = attrValues overlays; # ++ [ overlay-stable ];
    #     config.allowUnfree = true;
    #   }
    # );
    #
    # legacyPackagesStable = forAllSystems (system:
    #   import inputs.nixpkgs {
    #     inherit system;
    #     overlays = attrValues overlays; # ++ [ overlay-unstable ];
    #     config.allowUnfree = true;
    #   }
    # );
    

# NOTE: the updated way to do this is (after running current ./setup)
# nix shell nixpkgs#home-manager
# home-manager switch --flake .#[configname]
    
    # home-manager bootstrap script. If home-manager isn't yet installed, run
    # `nix shell .` and then `bootstrap [NAME OF HOME CONFIG]`
    # TODO: why isn't this just using the writeshellscript whatever?
    # checkout the bootstrap used in https://github.com/Misterio77/nix-starter-configs/blob/main/standard/shell.nix
    # packages = forAllSystems (system: {
    #   default = with legacyPackagesUnstable.${system}; 
    #   stdenv.mkDerivation rec {
    #     name = "bootstrap-script";
    #     installPhase = /* bash */ ''
    #       mkdir -p $out/bin
    #       echo "#!${runtimeShell}" >> $out/bin/bootstrap
    #       echo "export TERMINFO_DIRS=/usr/share/terminfo" >> $out/bin/bootstrap
    #       echo "nix build --no-write-lock-file home-manager" >> $out/bin/bootstrap
    #       echo "./result/bin/home-manager --flake \".#\$1\" switch --impure" >> $out/bin/bootstrap
    #       chmod +x $out/bin/bootstrap
    #     '';
    #     dontUnpack = true;
    #   };
    # });
  };
}
