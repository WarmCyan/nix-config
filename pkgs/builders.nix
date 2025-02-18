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
  if params != null then
  /* bash */ ''
    function parse_params () {
      positional_args=()
      local param
      while [[ $# -gt 0 ]]; do
        param="$1"
        shift
        case $param in
          ${paramsSwitchCollection params}
          *)
            positional_args+=("$param")
            ;;
        esac
      done
    }
  '' else "";
  
  parseParams = params:
  if params != null then /* bash */ ''
      parse_params "$@"
      set -- "''${positional_args[@]}"
    ''
    else "";

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

  versionCheck = version: params:
  if version != null && params != null then
  /* bash */ ''
    if [[ ''${version-false} == true ]]; then
      echo "${version}"
      exit 0;
    fi
  '' else "";

  helpCheck = params:
  if params != null then
  /* bash */ ''
    if [[ ''${help-false} == true ]]; then
      print_help
      exit 0;
    fi
  '' else "";

  # eventually need params to help do nocolor check
  colorInitFunction = initColors: params:
  if initColors then
  /* bash */ ''
  ${builtins.readFile ./color_init.sh}

  # SC2119 - yes I know I'm not passing local args yet
  # shellcheck disable=SC2119
  color_init
  '' else "";

  # TODO: nocolor check/init color check
  expandParameters = params: version: parameterParser:
  if parameterParser then (
  params // { 
    help = { 
      flags = [ "-h" "--help" ];
      description = "Display this help message.";
      option = true;
    };
  } // (if version != null then 
  {
    version = {
      flags = [ "--version" ];
      description = "Print the script version.";
      option = true;
    };
  } else {}))
  else null;

  fixMultiLineBashComment = fullString:
  builtins.replaceStrings [ "\n" ] [ "\n# " ] fullString;
  

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
      /* bash */ ''
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
    parameters ? {}, # expects a dictionary with descriptions and possible flags
    # e.g. parameters = { bash_var_name = { description = "testing"; flags = [
    # "-t" "--testing"; option = false ] } }
    initColors ? false,
    parameterParser ? true,
    runtimeInputs ? [ ],
    exitOnError ? true,
  }:
  let 
    resolved_params = expandParameters parameters version parameterParser;
  in
  writeVersionedTextFile {
    inherit name version;
    executable = true;
    destination = "/bin/${name}";
    
    # TODO: need to add the help/version/verbose/nocolor params
    # TODO: add debug stuff from script template
    
    # TODO: add header and license and stuff
    # TODO: add color stuff
    # TODO: how to deal with positional parameters?
    text = /* bash */ ''
      #!${pkgs.runtimeShell}
      
      # ===============================================================
      # ${name}${if version != null then " (${version})" else ""}
      # ${fixMultiLineBashComment description}
      #
      ${if usage != null then "# Usage: ${fixMultiLineBashComment usage}" else ""}
      # Author: Nathan Martindale
      # License: MIT
      # ===============================================================
      
      ${if exitOnError then "set -o errexit" else ""}
      set -o nounset
      set -o pipefail

      export PATH="${lib.makeBinPath runtimeInputs}:$PATH"

      ${parseParamsFunction resolved_params}

      ${helpFunction description usage resolved_params}

      ${parseParams resolved_params}

      ${helpCheck resolved_params}

      ${versionCheck version resolved_params}

      ${colorInitFunction initColors resolved_params}

      # ---------------------- MAIN SCRIPT CODE -----------------------
      
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
