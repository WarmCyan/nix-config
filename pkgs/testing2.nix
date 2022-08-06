{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "testing2";
  version = "0.2.0";
  usage = "testing2 [-t|--testing] [--yessir VALUE]";
  text = ''
    echo "sup dawg ''${thing1-} ''${yessir-yo}"

    if [[ $# -gt 0 ]]; then
      echo "$@"
    fi
  '';
  description = "things";
  parameters = {
    thing1 = { 
      flags = [ "-t" "--testing" ];
      description = "yeah";
      option = true;
    };
    yessir = {
      flags = [ "--yessir" ];
      description = "something man, I dunno";
    };
  };
}
