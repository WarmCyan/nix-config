# iris-manager - this is the management tool for my system, a script
# to interact with my nix-config flake and shortcuts for my common 
# commands

{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "iris";
  version = "0.1.0";
  description = "Management tool for my systems/nix-config flake.";
  usage = "";
  parameters = {
  };
  runtimeInputs = [ 
    pkgs.expect 
    pkgs.unstable.nix-output-monitor 
    # pkgs.testing2 # this just demonstrates that I can indeed require my own scripts
  ];
  text = /* bash */ ''
    echo 'hi!!';
  '';
}
