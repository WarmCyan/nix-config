# Personal packages list

{ pkgs, lib }: rec {
  
  builders = import ./builders.nix { inherit pkgs lib; };

  add-jupyter-env = pkgs.callPackage ./add-jupyter-env.nix { };

  iris = pkgs.callPackage ./iris.nix { inherit pkgs builders; };
  sri-hash = pkgs.callPackage ./sri-hash.nix { inherit builders; };
  mic-monitor = pkgs.callPackage ./mic-monitor.nix { inherit builders; };
  
  testing = pkgs.callPackage ./testing.nix { };
  testing2 = pkgs.callPackage ./testing2.nix { inherit builders; };
}
