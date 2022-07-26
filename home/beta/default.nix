{ pkgs, ... }:
{
  home.packages = with pkgs; [

    add-jupyter-env
    
    testing # my first nix shell package thingy!
  ];
}
