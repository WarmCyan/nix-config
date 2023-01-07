# TODO: at some point we could have flags to only print found tools, and to
# check more than just my stuff, but my common ones
# TODO: add a flag to allow running cli true/false (successful exit or not) check for specified tool
# should both print the badge and exit 0 or 1 (latter if not found)
# TODO: add version
{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "tools";
  version = "0.2.0";
  description = "Essentially a lister of my tools so I remember! And can quickly check which ones are installed";
  usage = "tools [-c|--check TOOL] [-q|--quiet]";
  initColors = true;
  parameters = {
    check = {
      flags = [ "-c" "--check" ];
      description = "Check if a specified tool exists in the path. Will exit non-zero if tool not found.";
    };
    quiet = {
      flags = [ "-q" "--quiet" ];
      description = "Don't print out any badges, but exit zero or non-zero if a tool found/not found.";
      option = true;
    };
  };
  text = /* bash */ ''

  function status_badge () {
    local status="''${1}"
    local message="''${2}"

    if [[ ''${status} == 0 ]]; then

      # exit based on status if quiet and don't print
      if [[ ''${quiet-false} == true ]]; then
        exit 0
      fi
    
      echo "''${bg_green}''${fg_black}  OK  ''${ta_none} ''${message}"

      # if this was one specific tool we were looking for, exit now
      if [[ "''${check-}" != "" ]]; then
        exit 0
      fi
    else
    
      # exit based on status if quiet and don't print
      if [[ ''${quiet-false} == true ]]; then
        exit 1
      fi
      
      echo "''${bg_red}''${fg_black} MISS ''${ta_none} ''${message}"
      
      # if this was one specific tool we were looking for, exit now
      if [[ "''${check-}" != "" ]]; then
        exit 1
      fi
    fi
  }
  
  function check_tool () {
    local tool="''${1}"
    exists=$(command -v "''${tool}" &> /dev/null; echo "$?")
    status_badge "''${exists}" "''${tool}"
  }


  if [[ "''${check-}" != "" ]]; then
    check_tool "''${check}"
  fi
  
  # my tools
  check_tool "iris"
  check_tool "export-dots"
  echo "------"
  check_tool "add-jupyter-env"
  check_tool "sri-hash"
  check_tool "td-state"
  echo "------"
  check_tool "mic-monitor"
  check_tool "kbd-capslock"
  '';
}

