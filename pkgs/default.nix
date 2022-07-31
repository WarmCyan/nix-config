# Personal packages list

{ pkgs, lib }: rec {
  
  builders = import ./builders.nix { inherit pkgs lib; };

  add-jupyter-env = pkgs.callPackage ./add-jupyter-env.nix { };
  
  testing = pkgs.callPackage ./testing.nix { };
  testing2 = pkgs.callPackage ./testing2.nix { inherit builders; };
}
