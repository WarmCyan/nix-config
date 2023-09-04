# iris-manager - this is the management tool for my system, a script
# to interact with my nix-config flake and shortcuts for my common 
# commands

# TODO: command to regenerate hardware config and copy in?
# TODO: once we store git hash, allow grabbing the git log up to that hash for given generation.

{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "iris";
  version = "1.0.3";
  description = "Management tool for my systems/nix-config flake.";
  usage = "iris {COMMAND:[(b|build)(e|edit)(n|new)(ls)(lsgen)(r|revert)]} {SYSTEMS:s/h} {CONFIG1} {CONFIG2} --yes --update\n\nExamples:\n\tiris b sh\n\tiris build s myconfig\n\tiris ls\n\tiris edit\n\tiris edit h phantom\n\tiris lsgen sh\n\tiris r sh 10 30\t# reverts system to system generation 10 and home to home generation 30";
  parameters = {
    sync = {
      flags = [ "-S" "--sync" ];
      description = "Sync the nix-config git repository. (This runs before a build step if specified)";
      option = true;
    };
    update = {
      flags = [ "-u" "--update" ];
      description = "Update the flake lock file. (This runs before a build step if specified)";
      option = true;
    };
    updatePinned = {
      flags = [ "--update-pinned" ];
      description = "Update the pinned nixpkgs version to the currently locked nixpkgs-unstable. (This runs before a build step if specified)";
      option = true;
    };
    yes = {
      flags = [ "-y" "--yes" ];
      description = "Automatically apply the (h)ome and/or (s)ystem configuration without prompting.";
      option = true;
    };
  };
  runtimeInputs = [ 
    pkgs.unstable.figlet # unstable to get new contributed fonts
    pkgs.unstable.nvd
    pkgs.lolcat
    pkgs.ripgrep
    pkgs.jq
    # pkgs.testing2 # this just demonstrates that I can indeed require my own scripts
  ];
  text = /* bash */ ''
    function print_header () {
      figlet -f cyberlarge IRIS | lolcat
    }

    function collect_and_print_info () {
      sys_config=""
      sys_hash=""
      sys_revCount=""
      sys_lastMod=""
      
      hm_config=""
      hm_hash=""
      hm_revCount=""
      hm_lastMod=""
      
      config_location=""
      
      if [[ -e "/nix/var/nix/profiles/system" ]]; then
        if [[ -e "/etc/iris/configname" ]]; then
          sys_config=$(cat "/etc/iris/configname")
        fi
        if [[ -e "/etc/iris/configlocation" ]]; then
          config_location=$(cat "/etc/iris/configlocation")
        fi
        if [[ -e "/etc/iris/configShortRev" ]]; then
          sys_hash=$(cat "/etc/iris/configShortRev")
        fi
        if [[ -e "/etc/iris/configRevCount" ]]; then
          sys_revCount=$(cat "/etc/iris/configRevCount")
          if [[ "''${sys_revCount}" == "dirty" ]]; then
            sys_revCount=""
          fi
        fi
        if [[ -e "/etc/iris/configLastModified" ]]; then
          sys_lastMod=$(cat "/etc/iris/configLastModified")
          if [[ "''${sys_lastMod}" != "dirty" ]]; then
            sys_lastMod=$(${pkgs.coreutils}/bin/date -d "@''${sys_lastMod}" +"%Y-%m-%d")
          fi
        fi
      
        system_generation_pointer=$(readlink "/nix/var/nix/profiles/system")
        system_generation_number=$(readlink "/nix/var/nix/profiles/system" | sed -e "s/[A-Za-z\-]*\([0-9]*\)/\1/g")
        #system_nix_store_pointer=$(readlink "/nix/var/nix/profiles/''${system_generation_pointer}")
        system_generation_date=$(${pkgs.coreutils}/bin/stat -c %y "/nix/var/nix/profiles/''${system_generation_pointer}")
        system_generation_date_time=''${system_generation_date:0:10}
        #echo -e "System gen: \t''${system_generation_number} (''${system_generation_date_time}) ''${sys_config} \tv''${sys_revCount}-''${sys_hash} (''${sys_lastMod})"
        printf "%-13s%-3s %-13s %-10s v%-12s (%s)\n" \
          "System gen:" \
          "''${system_generation_number}" \
          "(''${system_generation_date_time})" \
          "''${sys_config}" \
          "''${sys_revCount}-''${sys_hash}" \
          "''${sys_lastMod}"
        #echo -e "\t-> ''${system_nix_store_pointer}"
      fi

      hm_profile_base=""
      if [[ -e "/nix/var/nix/profiles/per-user/''${USER}/home-manager" ]]; then
        hm_profile_base="/nix/var/nix/profiles/per-user/''${USER}" 
      elif [[ -e "''${HOME}/.local/state/nix/profiles/home-manager" ]]; then
        hm_profile_base="''${HOME}/.local/state/nix/profiles"
      fi
      
      if [[ "$hm_profile_base" != "" ]]; then
        if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configname" ]]; then
          hm_config=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configname")
        fi
        if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configlocation" ]]; then
          config_location=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configlocation")
        fi
        if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configShortRev" ]]; then
          hm_hash=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configShortRev")
        fi
        if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configRevCount" ]]; then
          hm_revCount=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configRevCount")
          if [[ "''${hm_revCount}" == "dirty" ]]; then
            hm_revCount=""
          fi
        fi
        if [[ -e "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configLastModified" ]]; then
          hm_lastMod=$(cat "''${XDG_DATA_HOME-$HOME/.local/share}/iris/configLastModified")
          if [[ "''${hm_lastMod}" != "dirty" ]]; then
            hm_lastMod=$(${pkgs.coreutils}/bin/date -d "@''${hm_lastMod}" +"%Y-%m-%d")
          fi
        fi
      
        hm_generation_pointer=$(readlink "''${hm_profile_base}/home-manager")
        hm_generation_number=$(readlink "''${hm_profile_base}/home-manager" | sed -e "s/[A-Za-z\-]*\([0-9]*\)/\1/g")
        #hm_nix_store_pointer=$(readlink "/nix/var/nix/profiles/''${hm_generation_pointer}")
        hm_generation_date=$(${pkgs.coreutils}/bin/stat -c %y "''${hm_profile_base}/''${hm_generation_pointer}")
        hm_generation_date_time=''${hm_generation_date:0:10}
        #echo -e "Home gen: \t''${hm_generation_number} (''${hm_generation_date_time}) ''${hm_config} \tv''${hm_revCount}-''${hm_hash} (''${hm_lastMod})"
        printf "%-13s%-3s %-13s %-10s v%-12s (%s)\n" \
          "Home gen:" \
          "''${hm_generation_number}" \
          "(''${hm_generation_date_time})" \
          "''${hm_config}" \
          "''${hm_revCount}-''${hm_hash}" \
          "''${hm_lastMod}"
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

    function sync_repo () { 
      echo -e "\nSyncing configuration repository..."
      ensure_config
      pushd "''${config_location}" &> /dev/null
        git pull
      popd &> /dev/null
    }

    function update_flake () {
      echo -e "\nUpdating nix flake..."
      ensure_config
      pushd "''${config_location}" &> /dev/null
        nix flake update
      popd &> /dev/null
    }

    function build_system () {
      echo -e "\nRunning system build..."
      ensure_config
      pushd "''${config_location}" &> /dev/null

        # TODO: check for if we're not on nixos (sys_config is "")

        config_file="''${sys_config}"
        if [[ "$1" != "" ]]; then
          config_file="$1"
        fi
        if [[ "''${config_file}" == "" ]]; then
          echo "System build was requested, but no configuration name was specified and no previous configuration was found. Please run 'iris build s [CONFIGNAME]'"
          exit 1
        fi
      
        nixos-rebuild build --fast --flake .\#"''${config_file}"
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
                echo "Build results are at ''${config_location}/result-system, they can be manually inspected and applied by navigating to its bin/ directory and running 'switch-to-configuration switch'."
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
        sudo nix-env --profile /nix/var/nix/profiles/system --set ./result-system
        sudo result-system/bin/switch-to-configuration switch
      popd &> /dev/null
    }
    
    function build_home () {
      echo -e "\nRunning home build..."
      ensure_config
      pushd "''${config_location}" &> /dev/null

        # TODO: handle if home-manager not in use

        config_file="''${hm_config}"
        if [[ "$1" != "" ]]; then
          config_file="$1"
        fi
        if [[ "''${config_file}" == "" ]]; then
          echo "Home build was requested, but no configuration name was specified and no previous configuration was found. Please run 'iris build h [CONFIGNAME]'"
          exit 1
        fi
        
        hm_profile_base=""
        if [[ -e "/nix/var/nix/profiles/per-user/''${USER}/home-manager" ]]; then
          hm_profile_base="/nix/var/nix/profiles/per-user/''${USER}" 
        elif [[ -e "''${HOME}/.local/state/nix/profiles/home-manager" ]]; then
          hm_profile_base="''${HOME}/.local/state/nix/profiles"
        fi
        
        home-manager build --flake .\#"''${hm_config}"
        rm -f result-home
        mv result result-home
        nvd diff "''${hm_profile_base}/home-manager" result-home
        
        if [[ ''${yes-false} == false ]]; then
          # prompt loop
          valid_response=false
          while [[ ''${valid_response} == false ]]; do
            read -r -p "Apply home build result? [Y/n]" response 
            case "''${response}" in
              [nN][oO]|[nN])
                echo "Home build not applied."
                echo "Build results are at ''${config_location}/result-home, they can be manually inspected and applied by running 'activate' in its root directory."
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
        echo "Applying home result..."
        nix-env --profile "''${hm_profile_base}/home-manager" --set ./result-home  # TODO: what does this do?
        result-home/activate
      popd &> /dev/null
    }

    function list_home_configs () {
      ensure_config
      echo -e "\nAvailable home configurations:"
      grep -P ".*\ =\ mkHome" "''${config_location}/flake.nix" | sed -e "s/\s*\([A-Za-z0-9\-\_\@]*\)\ =.*/\1/g"
    }

    function list_system_configs () {
      ensure_config
      echo -e "\nAvailable system configurations:"
      # the -P is necessary for grep to handle the parens correctly (perl regex?)
      grep -P ".*\ =\ mk(StableSystem|System)" "''${config_location}/flake.nix" | sed -e "s/\s*\([A-Za-z0-9\-\_\@]*\)\ =.*/\1/g"
    }

    function list_home_gens () {
      ensure_config
      
      hm_profile_base=""
      if [[ -e "/nix/var/nix/profiles/per-user/''${USER}/home-manager" ]]; then
        hm_profile_base="/nix/var/nix/profiles/per-user/''${USER}" 
      elif [[ -e "''${HOME}/.local/state/nix/profiles/home-manager" ]]; then
        hm_profile_base="''${HOME}/.local/state/nix/profiles"
      fi
        
      echo -e "\nPrevious clean home generations:"
      printf "%-5s   %-12s   %-12s\n" "GEN" "GEN DATE" "GIT VERSION"
      echo "------------------------------------"
      printf "Collecting...\r"
      if [[ -e "''${hm_profile_base}/home-manager" ]]; then
        pushd "''${hm_profile_base}" &> /dev/null

        {
          for filepath in home-manager-*-link; do
            #echo "''${filepath}"
            # shellcheck disable=SC2001
            gen_num=$(echo "''${filepath}" | sed -e "s/[A-Za-z\-]*\([0-9]*\)/\1/g")
            
            hm_conf_hash=""
            hm_conf_revCount=""
            hm_conf_lastMod=""
            
            full_path="''${hm_profile_base}/''${filepath}"
            if [[ -e "''${full_path}/home-files/.local/share/iris/configShortRev" ]]; then
              hm_conf_hash=$(cat "''${full_path}/home-files/.local/share/iris/configShortRev")
            fi
            if [[ -e "''${full_path}/home-files/.local/share/iris/configRevCount" ]]; then
              hm_conf_revCount=$(cat "''${full_path}/home-files/.local/share/iris/configRevCount")
              if [[ "''${hm_conf_revCount}" == "dirty" ]]; then
                hm_conf_revCount=""
              fi
            fi
            if [[ -e "''${full_path}/home-files/.local/share/iris/configLastModified" ]]; then
              hm_conf_lastMod=$(cat "''${full_path}/home-files/.local/share/iris/configLastModified")
              if [[ "''${hm_conf_lastMod}" != "dirty" ]]; then
                hm_conf_lastMod=$(${pkgs.coreutils}/bin/date -d "@''${hm_conf_lastMod}" +"%Y-%m-%d")
              fi
            fi
            hm_conf_generation_date=$(${pkgs.coreutils}/bin/stat -c %y "''${hm_profile_base}/''${filepath}")
            hm_conf_generation_date_time=''${hm_conf_generation_date:0:10}
            if [[ "''${hm_conf_revCount}" == "" ]]; then
              continue
            fi

            printf "%-5s - %-12s - v%-12s\n" "''${gen_num}" "(''${hm_conf_generation_date_time})" "''${hm_conf_revCount}-''${hm_conf_hash}"
          done
        } 2>&1 | sort -n | cat

        popd &> /dev/null
      fi
    }
    
    function list_sys_gens () {
      ensure_config
      echo -e "\nPrevious clean system generations:"
      printf "%-5s   %-12s   %-12s\n" "GEN" "GEN DATE" "GIT VERSION"
      echo "------------------------------------"
      printf "Collecting...\r"
      if [[ -e "/nix/var/nix/profiles/system" ]]; then
        pushd "/nix/var/nix/profiles/" &> /dev/null

        {
          for filepath in system-*-link; do
            #echo "''${filepath}"
            # shellcheck disable=SC2001
            gen_num=$(echo "''${filepath}" | sed -e "s/[A-Za-z\-]*\([0-9]*\)/\1/g")
            
            system_hash=""
            system_revCount=""
            system_lastMod=""
            
            full_path="/nix/var/nix/profiles/''${filepath}"
            if [[ -e "''${full_path}/etc/iris/configShortRev" ]]; then
              system_hash=$(cat "''${full_path}/etc/iris/configShortRev")
            fi
            if [[ -e "''${full_path}/etc/iris/configRevCount" ]]; then
              system_revCount=$(cat "''${full_path}/etc/iris/configRevCount")
              if [[ "''${system_revCount}" == "dirty" ]]; then
                system_revCount=""
              fi
            fi
            if [[ -e "''${full_path}/etc/iris/configLastModified" ]]; then
              system_lastMod=$(cat "''${full_path}/etc/iris/configLastModified")
              if [[ "''${system_lastMod}" != "dirty" ]]; then
                system_lastMod=$(${pkgs.coreutils}/bin/date -d "@''${system_lastMod}" +"%Y-%m-%d")
              fi
            fi
            system_generation_date=$(${pkgs.coreutils}/bin/stat -c %y "/nix/var/nix/profiles/''${filepath}")
            system_generation_date_time=''${system_generation_date:0:10}
            if [[ "''${system_revCount}" == "" ]]; then
              continue
            fi

            printf "%-5s - %-12s - v%-12s\n" "''${gen_num}" "(''${system_generation_date_time})" "''${system_revCount}-''${system_hash}"
          done
        } 2>&1 | sort -n | cat

        popd &> /dev/null
      fi
    }

    function activate_previous_home_gen () {
      # NOTE: expects to be passed a string number
      ensure_config
      echo -e "\nRe-activiating previous home generation ''${1}..."
      
      hm_profile_base=""
      if [[ -e "/nix/var/nix/profiles/per-user/''${USER}/home-manager" ]]; then
        hm_profile_base="/nix/var/nix/profiles/per-user/''${USER}" 
      elif [[ -e "''${HOME}/.local/state/nix/profiles/home-manager" ]]; then
        hm_profile_base="''${HOME}/.local/state/nix/profiles"
      fi
      
      if [[ -e "''${hm_profile_base}/home-manager-''${1}-link" ]]; then

        nvd diff "''${hm_profile_base}/home-manager" "''${hm_profile_base}/home-manager-''${1}-link"
        
        if [[ ''${yes-false} == false ]]; then
          # prompt loop
          valid_response=false
          while [[ ''${valid_response} == false ]]; do
            read -r -p "Apply previous home generation result? [Y/n]" response 
            case "''${response}" in
              [nN][oO]|[nN])
                echo "Previous home generation not applied."
                return
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
      
        echo "Applying home generation ''${1}..."
        # shellcheck disable=SC1090
        . "''${hm_profile_base}/home-manager-''${1}-link/activate"
      else
        echo "Could not find generation, use the 'iris lsgen' command to list valid generation numbers."
        exit 1
      fi
    }
    
    function activate_previous_sys_gen () {
      # NOTE: expects to be passed a string number
      ensure_config
      echo -e "\nRe-activiating previous system generation ''${1}..."
      
      if [[ -e "/nix/var/nix/profiles/system-''${1}-link" ]]; then

        nvd diff "/nix/var/nix/profiles/system" "/nix/var/nix/profiles/system-''${1}-link"
        
        if [[ ''${yes-false} == false ]]; then
          # prompt loop
          valid_response=false
          while [[ ''${valid_response} == false ]]; do
            read -r -p "Apply previous system result? [Y/n]" response 
            case "''${response}" in
              [nN][oO]|[nN])
                echo "Previous system generation not applied."
                return
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
      
        echo "Applying system generation ''${1}..."
        # shellcheck disable=SC1090
        . "/nix/var/nix/profiles/system-''${1}-link/activate"
      else
        echo "Could not find generation, use the 'iris lsgen' command to list valid generation numbers."
        exit 1
      fi
    }

    function update_pinned_nixpkgs () {
      # finds out the current rev of nixpkgs-unstable in local flake lock, 
      # then modifies flake nixpkgs-pinned to that rev, after ensuring pinned
      # isn't already in use anywhere
      ensure_config

      # make sure we're not using pinned somewhere
      echo -e "\nChecking for existing pinned package usage..."
      pushd "''${config_location}" &> /dev/null
        found=false
        
        # check in the home configs
        pushd home &> /dev/null
          if rg "pinned\."; then
            found=true
          fi
        popd &> /dev/null
        
        # check in the nixos system configs
        pushd hosts &> /dev/null
          if rg "pinned\."; then
            found=true
          fi
        popd &> /dev/null


        if [[ ''${found} == true ]]; then
          echo "WARNING: existing uses of pinned packages found, updating pinned channel before changing these could lead to unintended breakages!"
          # prompt loop
          valid_response=false
          while [[ ''${valid_response} == false ]]; do
            read -r -p "Update nixpkgs-pinned anyway? [y/n]" response 
            case "''${response}" in
              [nN][oO]|[nN])
                echo "Not updating pinned nixpkgs."
                exit 1
                ;;
              [yY][eE][sS]|[yY])
                valid_response=true
                break
                ;;
              *)
                echo "Invalid response, please enter [y]es or [n]o." 
                ;;
            esac
          done
        fi
        
        # get current nixpkgs-unstable revision
        unstableRevision=$(jq -r '.nodes."nixpkgs-unstable"'.locked.rev flake.lock)

        echo "Updating flake pinned nixpkgs to revision ''${unstableRevision}"
        # change the flake.nix (danger!)
        sed -i -E "s/nixpkgs\-pinned.url\ =\ .*\;\$/nixpkgs\-pinned.url\ =\ \"github:nixos\/nixpkgs?rev=''${unstableRevision}\";/" flake.nix
      popd &> /dev/null
    }

    function open_for_edit () {
      ensure_config
      pushd "''${config_location}" &> /dev/null
      # NOTE: vim is not in requested runtimeInputs because we're assuming nvim
      # is on the machine - this is a potentially faulty assumption...but I want
      # to use whatever is already there.
      
      if [[ $# -gt 1 ]]; then
        echo -e "\nEditing $1 and $2..."
        ''${EDITOR:=vim} -O "$1" "$2"
      else
        echo -e "\nEditing $1..."
        ''${EDITOR:=vim} "$1"
      fi
      popd &> /dev/null
    }
    
    print_header
    collect_and_print_info

    #echo "''${sys_config}" # yes this works


    if [[ ''${sync-false} == true ]]; then
      sync_repo
    fi

    # NOTE: we have to run update-pinned before a regular update! 
    # this allows us to both update pinned and the regular nixpkgs-unstable
    # without changing them both to the same latest nixpkgs-unstable
    if [[ ''${updatePinned--false} == true ]]; then
      update_pinned_nixpkgs
    fi

    if [[ ''${update-false} == true ]]; then
      update_flake
    fi

    if [[ $# -gt 0 ]]; then
      cmd_word=$1

      # positional argument parsing
      if [[ $# -gt 1 ]]; then
        config_types=$2
      else
        config_types=""
      fi
      if [[ $# -gt 2 ]]; then
        config1=$3
        if [[ $# -gt 3 ]]; then
          config2=$4
        else
          config2=$3
        fi
      else
        config1=""
        config2=""
      fi

      # command word
      case "''${cmd_word}" in
        b|build)
          case "''${config_types}" in
            sh)
              build_system "''${config1}"
              build_home "''${config2}"
              ;;
            hs)
              build_system "''${config2}"
              build_home "''${config1}"
              ;;
            s)
              build_system "''${config1}"
              ;;
            h)
              build_home "''${config1}"
              ;;
            *)
              echo "Invalid config types, please specify 'h' and/or 's'"
              exit 1
              ;;
          esac
          ;;
        e|edit)
          case "''${config_types}" in
            sh)
              config_path1="''${config1}"
              if [[ "''${config_path1}" == "" ]]; then
                config_path1="''${sys_config}"
              fi
              config_path2="''${config2}"
              if [[ "''${config_path2}" == "" ]]; then
                config_path2="''${hm_config}"
              fi
              config_path1="hosts/''${config_path1}/default.nix"
              config_path2="home/''${config_path2}/default.nix"

              open_for_edit "''${config_path1}" "''${config_path2}"
              ;;
            hs)
              config_path1="''${config1}"
              if [[ "''${config_path1}" == "" ]]; then
                config_path1="''${hm_config}"
              fi
              config_path2="''${config2}"
              if [[ "''${config_path2}" == "" ]]; then
                config_path2="''${sys_config}"
              fi
              config_path1="home/''${config_path1}/default.nix"
              config_path2="hosts/''${config_path2}/default.nix"

              open_for_edit "''${config_path1}" "''${config_path2}"
              ;;
            s)
              config_path1="''${config1}"
              if [[ "''${config_path1}" == "" ]]; then
                config_path1="''${sys_config}"
              fi
              config_path1="hosts/''${config_path1}/default.nix"
              open_for_edit "''${config_path1}"
              ;;
            h)
              config_path1="''${config1}"
              if [[ "''${config_path1}" == "" ]]; then
                config_path1="''${hm_config}"
              fi
              config_path1="home/''${config_path1}/default.nix"
              open_for_edit "''${config_path1}"
              ;;
            *)
              echo "Invalid config types, please specify 'h' and/or 's'"
              exit 1
              ;;
          esac
          ;;
        n|new)
          # TODO: give an option to copy an existing config, and use fzf/bat
          # with just the appropriate default.nix files to show them.
          ;;
        ls)
          case "''${config_types}" in
            hs|sh|"")
              list_home_configs
              list_system_configs
              ;;
            h)
              list_home_configs
              ;;
            s)
              list_system_configs
              ;;
            *)
              echo "Invalid config types, please specify 'h' and/or 's'"
              exit 1
              ;;
          esac
          ;;
        lsgen)
          case "''${config_types}" in
            hs|sh|"")
              list_home_gens
              list_sys_gens
              ;;
            h)
              list_home_gens
              ;;
            s)
              list_sys_gens
              ;;
            *)
              echo "Invalid config types, please specify 'h' and/or 's'"
              exit 1
              ;;
          esac
          ;;
        r|revert)
          if [[ "''${config1}" == "" ]]; then
            echo "Please specify a generation number to revert to."
            exit 1
          fi
          case "''${config_types}" in
            sh)
              if [[ "''${config2}" == "" ]]; then
                echo "Please specify both generation numbers to revert to."
                exit 1
              fi
              activate_previous_home_gen "''${config2}"
              activate_previous_sys_gen "''${config1}"
              ;;
            hs)
              if [[ "''${config2}" == "" ]]; then
                echo "Please specify both generation numbers to revert to."
                exit 1
              fi
              activate_previous_home_gen "''${config1}"
              activate_previous_sys_gen "''${config2}"
              ;;
            h)
              activate_previous_home_gen "''${config1}"
              ;;
            s)
              activate_previous_sys_gen "''${config1}"
              ;;
            *)
              echo "Invalid config types, please specify 'h' and/or 's'"
              exit 1
              ;;
          esac
          ;;
        *)
          echo "Invalid command, please specify [b|build]|[e|edit]|[n|new]|[r|revert]|ls|lsgen"
          exit 1
          ;;
      esac
    fi
  '';
}
