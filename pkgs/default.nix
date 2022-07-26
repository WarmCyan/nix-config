# Personal packages list

{ pkgs }: {


  add-jupyter-env = pkgs.callPackage ./add-jupyter-env.nix { };
  
  testing = pkgs.callPackage ./testing.nix { };
}
