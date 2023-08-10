# a quick launcher for a pluto julia notebook

{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "pluto";
  description = "Launcher for pluto julia notebook.";
  usage = "pluto";
  runtimeInputs = [
    pkgs.julia-bin
  ];
  text = /* bash */ ''
  julia -e "import Pkg; Pkg.add(\"Pluto\"); import Pluto; Pluto.run(auto_reload_from_file=true)"
  '';
}
