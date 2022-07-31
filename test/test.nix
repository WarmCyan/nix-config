# NOTE: use :r in repl to allow reloading stuff
rec {
  params = import ./params.nix;
  thing = import ./monster.nix { parameters = params; };
}
