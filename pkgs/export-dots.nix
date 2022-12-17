
# the IDEA: for this will be to create an "export folder" that's timestamped and
# has current git version info etc.

{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "export-dots";
  version = "0.1.0";
  description = "Turn nix-ified configs and scripts into non-nix-ified versions, so they can be copied onto systems that are too hard to get nix onto.";
  usage = "export-dots";
  parameters = {};
  text = /* bash */ ''

  export_folder="test_export"
  mkdir -p "''${export_folder}"
  mkdir -p "''${export_folder}/home"
  

  function export_bashrc {
    target_bashrc="''${export_folder}/home/.bashrc"
    cp ~/.bashrc "''${target_bashrc}"
    chmod 777 "''${target_bashrc}"
    
    # fix micromamba nix paths
    sed -i -E "s/(.*)\/nix\/store\/.*\/bin\/micromamba(.*)/\1micromamba\2/g" "''${target_bashrc}"

    # remove bash_completion path
    sed -i "/.*BASH_COMPLETION_VERSINFO.*/d" "''${target_bashrc}"
    sed -i "/.*profile.d\/bash_completion.sh.*/,+1d" "''${target_bashrc}"
  }
  
  # function export_tmux {
  # }

  export_bashrc
  '';
}
