{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "testing2";
  # version = "0.2.0";
  text = "echo \"sup dawg \${thing1-} \${yessir-yo}\"";
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
