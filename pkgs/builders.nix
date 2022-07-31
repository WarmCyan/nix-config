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
    function parse_params() {
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
    version ? null,
    description,
    parameters ? null, # expects a dictionary with descriptions and possible flags
    # e.g. parameters = { bash_var_name = { description = "testing"; flags = [
    # "-t" "--testing"; option = false ] } }
    initColors ? false,
    runtimeInputs ? [ ]
  }:
  writeVersionedTextFile {
    inherit name version;
    executable = true;
    destination = "/bin/${name}";
    
    # TODO: need to add the help/version/verbose/nocolor params
    
    # TODO: add header and license and stuff
    # TODO: add color stuff
    # NOTE: is runtimeShell supposed to come from pkgs?
    text = ''
      #!${pkgs.runtimeShell}
      # 
      
      set -o errexit
      set -o nounset
      set -o pipefail

      export PATH="${lib.makeBinPath runtimeInputs}:$PATH"

      ${parseParamsFunction parameters}

      parse_params "$@"

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
