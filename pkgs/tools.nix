# TODO: at some point we could have flags to only print found tools, and to
# check more than just my stuff, but my common ones
{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "tools";
  description = "Essentially a lister of my tools so I remember!";
  usage = "tools";
  initColors = true;
  parameters = {};
  text = /* bash */ ''

  function status_badge () {
    local status="''${1}"
    local message="''${2}"

    if [[ ''${status} == 0 ]]; then
        echo "''${bg_green}''${fg_black}  OK  ''${ta_none} ''${message}"
    else
        echo "''${bg_red}''${fg_black} MISS ''${ta_none} ''${message}"
    fi
  }
  
  function check_tool () {
    local tool="''${1}"
    exists=$(command -v "''${tool}" &> /dev/null; echo "$?")
    status_badge "''${exists}" "''${tool}"
  }


  # my tools
  echo "Checking installation of custom tools in path..."
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

