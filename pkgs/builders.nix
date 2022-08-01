# functions for making it easy to write well formed, templated bin scripts
{ pkgs, lib }: rec {


  paramFlagList = param: builtins.concatStringsSep " | " param.flags;
  paramSwitch = name: param: 
    if param ? option && param.option then 
      /* bash */ ''
        ${name}=true
        ;;
      ''
    else
      /* bash */ ''
        ${name}=$1
        shift
        ;;
      '';
  paramsSwitchCollection = params:
  builtins.concatStringsSep ""
  (builtins.attrValues 
  (if params != null then
  builtins.mapAttrs (name: param: ''
    ${paramFlagList param})
    ${paramSwitch name param}''
  ) params else ""));
  
  parseParamsFunction = params:
  /* bash */ ''
    function parse_params () {
      local param
      while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
          ${paramsSwitchCollection params}
        esac
      done
    }
  '';

  helpParameters = params:
  builtins.concatStringsSep "\n"
  (builtins.attrValues 
  (if params != null then
  builtins.mapAttrs (name: param: 
  ''echo -e "  ${builtins.concatStringsSep " " param.flags}\t\t${param.description}"''
  ) params else ""));
  

  helpFunction = description: usage: params: 
  /* bash */ ''
  function print_help () {
    echo "${description}"
    ${if usage != null then "echo -e \"\\nusage: ${usage}\"" else ""}
    echo ""
    ${helpParameters params}
  }
  '';

  versionCheck = version:
  if version != null then
  /* bash */ ''
    if [[ ''${version-false} == true ]]; then
      echo "${version}"
      exit 0;
    fi
  '' else "";

  # TODO: nocolor check/init color check
  expandParameters = params: version:
  params // { 
    help = { 
      flags = [ "-h" "--help" ];
      description = "Display this help message.";
      option = true;
    };
  } // (if version != null then 
  {
    version = {
      flags = [ "-v" "--version" ];
      description = "Print the script version.";
      option = true;
    };
  } else {});
  

  # allow a version number to be associated with a text file
  # this is basically a direct copy of trivial builders writeTextFile, but with
  # name and version included
  writeVersionedTextFile = 
  { name # the name of the derivation
    , text
    , version ? null
    , executable ? false # run chmod +x ?
    , destination ? ""   # relative path appended to $out eg "/bin/foo"
    , checkPhase ? ""    # syntax checks, e.g. for scripts
    , meta ? { }
  }:
    pkgs.runCommand (if version != null then "${name}-${version}" else name)
      { inherit text executable checkPhase meta version;
        pname = name;
        passAsFile = [ "text" ];
        # Pointless to do this on a remote machine.
        preferLocalBuild = true;
        allowSubstitutes = false;
      }
      ''
        target=$out${lib.escapeShellArg destination}
        mkdir -p "$(dirname "$target")"
        if [ -e "$textPath" ]; then
          mv "$textPath" "$target"
        else
          echo -n "$text" > "$target"
        fi
        eval "$checkPhase"
        (test -n "$executable" && chmod +x "$target") || true
      '';

  # NOTE: to make this suitable for non-nix contexts, after the build, remove
  # the shebang line and the export PATH line 
  # NOTE: don't forget you can use variables from parameters like
  # ${myparam-DEFAULTVAL} 
  writeTemplatedShellApplication = { 
    name,
    text,
    description,
    version ? null,
    usage ? null,
    parameters ? null, # expects a dictionary with descriptions and possible flags
    # e.g. parameters = { bash_var_name = { description = "testing"; flags = [
    # "-t" "--testing"; option = false ] } }
    initColors ? false,
    parameterParser ? true,
    runtimeInputs ? [ ]
    
  }:
  writeVersionedTextFile {
    inherit name version;
    executable = true;
    destination = "/bin/${name}";
    
    # TODO: need to add the help/version/verbose/nocolor params
    # TODO: add debug stuff from script template
    
    # TODO: add header and license and stuff
    # TODO: add color stuff
    text = ''
      #!${pkgs.runtimeShell}
      
      # ===============================================================
      # ${name}${if version != null then " (${version})" else ""}
      # ${description}
      # ===============================================================
      
      set -o errexit
      set -o nounset
      set -o pipefail

      export PATH="${lib.makeBinPath runtimeInputs}:$PATH"

      ${parseParamsFunction (expandParameters parameters version)}

      ${helpFunction description usage (expandParameters parameters version)}

      parse_params "$@"

      if [[ ''${help-false} == true ]]; then
        print_help
        exit 0;
      fi

      ${versionCheck version}

      # ---------- MAIN SCRIPT CODE ----------
      
      ${text}
    '';
    
    checkPhase = ''
      runHook preCheck
      ${pkgs.stdenv.shellDryRun} "$target"
      ${pkgs.shellcheck}/bin/shellcheck "$target"
      ${pkgs.shfmt}/bin/shfmt --indent 2 --case-indent --write "$target"
      runHook postCheck
    '';
    
    meta.mainProgram = name;
  };


  

  myWriteShellApplication = { name, text }:
  pkgs.writeShellApplication { 
    name = name;
    text = ''
      ${text}

      echo 'whaaaaaaaaaat????'
    '';
  };
  
}
