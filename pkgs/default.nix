# Personal packages list

{ pkgs, lib }: rec {
  
  builders = import ./builders.nix { inherit pkgs lib; };

  add-jupyter-env = pkgs.callPackage ./add-jupyter-env.nix { };

  iris = pkgs.callPackage ./iris.nix { inherit pkgs builders; };
  sri-hash = pkgs.callPackage ./sri-hash.nix { inherit builders; };
  mic-monitor = pkgs.callPackage ./mic-monitor.nix { inherit pkgs builders; };
  td-state = pkgs.callPackage ./td-state.nix { inherit builders; };
  engilog = pkgs.callPackage ./engilog.nix { inherit builders; };

  gifify = pkgs.callPackage ./gifify.nix { inherit builders; };

  kbd-capslock = pkgs.callPackage ./kbd-capslock.nix { inherit pkgs builders; };
  
  export-dots = pkgs.callPackage ./export-dots.nix { inherit pkgs builders; };

  tools = pkgs.callPackage ./tools.nix { inherit pkgs builders; };
  pluto = pkgs.callPackage ./pluto.nix { inherit pkgs builders; };

  volume = pkgs.callPackage ./barscripts/volume.nix { };
  batt = pkgs.callPackage ./barscripts/batt.nix { };
  
  testing = pkgs.callPackage ./testing.nix { };
  testing2 = pkgs.callPackage ./testing2.nix { inherit builders; };
}
