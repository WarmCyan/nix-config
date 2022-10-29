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
    update = {
      flags = [ "-u" "--update" ];
      description = "Update the flake lock file. (This runs before a build step if specified)";
      option = true;
    };
    build = {
      flags = [ "-b" "--build" ];
      description = "Build the specified (h)ome and/or (s)ystem configuration, and switch";
      option = true;
    };
    yes = {
      flags = [ "-y" "--yes" ];
      description = "Automatically apply the (h)ome and/or (s)ystem configuration without prompting.";
      option = true;
    };
  };
  runtimeInputs = [ 
    pkgs.expect 
    pkgs.unstable.nix-output-monitor 
    pkgs.unstable.figlet # unstable to get new contributed fonts
    pkgs.unstable.nvd
    pkgs.lolcat
    # pkgs.testing2 # this just demonstrates that I can indeed require my own scripts
  ];
  text = /* bash */ ''

    # make pushd and popd silent
    # pushd () {
    #   command pushd "$@" &> /dev/null
    # }
    # popd () {
    #   command popd "$@" &> /dev/null
    # }


    function print_header () {
      figlet -f cyberlarge IRIS | lolcat
    }

    function collect_and_print_info () {
      sys_config=""
      hm_config=""
      config_location=""
      
      if [[ -e "/nix/var/nix/profiles/system" ]]; then
        if [[ -e "/etc/iris/configname" ]]; then
          sys_config=$(cat "/etc/iris/configname")
        fi
        if [[ -e "/etc/iris/configlocation" ]]; then
          config_location=$(cat "/etc/iris/configlocation")
        fi
      
        system_generation_pointer=$(readlink "/nix/var/nix/profiles/system")
        #system_nix_store_pointer=$(readlink "/nix/var/nix/profiles/''${system_generation_pointer}")
        system_generation_date=$(stat -c %y "/nix/var/nix/profiles/''${system_generation_pointer}")
        system_generation_date_time=''${system_generation_date:0:10}
        echo "System generation: ''${system_generation_pointer} (''${system_generation_date_time}) - ''${sys_config}"
        #echo -e "\t-> ''${system_nix_store_pointer}"
      fi
      
      if [[ -e "/nix/var/nix/profiles/per-user/''${USER}/home-manager" ]]; then
        if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configname" ]]; then
          hm_config=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configname")
        fi
        if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configlocation" ]]; then
          config_location=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configlocation")
        fi
      
        hm_generation_pointer=$(readlink "/nix/var/nix/profiles/per-user/''${USER}/home-manager")
        #hm_nix_store_pointer=$(readlink "/nix/var/nix/profiles/''${hm_generation_pointer}")
        hm_generation_date=$(stat -c %y "/nix/var/nix/profiles/per-user/''${USER}/''${hm_generation_pointer}")
        hm_generation_date_time=''${hm_generation_date:0:10}
        echo "Home generation: ''${hm_generation_pointer} (''${hm_generation_date_time}) - ''${hm_config}"
        #echo -e "\t-> ''${hm_nix_store_pointer}"
      fi
    }

    function ensure_config () {
      if [[ "''${config_location}" == "" ]]; then
        echo "ERROR: no nix-config location data found."
        exit 1
      fi
    
      # clone repository if we don't find it in the correct location - this is
      # for if you cloned it somewhere else for some reason first
      if [[ ! -e "''${config_location}" ]]; then
        echo "Config location was empty, cloning repository..."
        git clone https://github.com/WildfireXIII/nix-config.git "''$config_location"
      fi
    }

    function update_flake () {
      echo "Updating nix flake..."
      ensure_config
      pushd "''${config_location}" &> /dev/null
        nix flake update
      popd &> /dev/null
    }

    function build_system () {
      echo "Running system build..."
      ensure_config
      pushd "''${config_location}" &> /dev/null

        # TODO: handle if another configuration was specified (this will be the
        # second positional argument, and should only work if only 's' was
        # specified
      
        nixos-rebuild build --fast --flake .\#"''${sys_config}"
        rm -f result-system
        mv result result-system
        nvd diff "/nix/var/nix/profiles/system" result-system
        
        if [[ ''${yes-false} == false ]]; then
          # prompt loop
          valid_response=false
          while [[ ''${valid_response} == false ]]; do
            read -r -p "Apply system result? [Y/n]" response 
            case "''${response}" in
              [nN][oO]|[nN])
                echo "System build not applied."
                echo "Build results are at ''${config_location}/result-system, they can be manually inspected and applied by navigating to its bin/ directory and running 'switch-to-configuration switch'"
                exit 0
                ;;
              [yY][eE][sS]|[yY])
                valid_response=true
                break
                ;;
              "")
                valid_response=true
                break
                ;;
              *)
                echo "Invalid response, please enter [y]es or [n]o." 
                ;;
            esac
          done
        fi

        # if we've hit this point, we're good to do the build! 
        echo "Applying system result..."
        sudo result-system/bin/switch-to-configuration switch
      popd &> /dev/null
    }

    print_header
    collect_and_print_info

    #echo "''${sys_config}" # yes this works


    if [[ ''${update-false} == true ]]; then
      update_flake
    fi

    if [[ $# -gt 0 ]]; then
      # TODO: life will be easier if we handle this with case like we do the
      # yes/no above
      if [[ "$1" == "s" || "$1" == "hs" || "$1" == "sh" ]]; then
        if [[ ''${build-false} == true ]]; then
          build_system
        fi

        # TODO: handle just displaying lots more info about the system
        # generation
      fi
    fi
  '';
}
