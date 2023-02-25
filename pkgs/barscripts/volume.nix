# loosely inspired by 
# https://github.com/polybar/polybar-scripts/pull/320/files
{ writeShellApplication, pkgs }:
writeShellApplication {
  name = "volume";
  runtimeInputs = [ pkgs.pamixer ];
  text = /* bash */ ''
  
  if [[ $# -gt 0 ]]; then
    case $1 in 
      "up")
        pamixer --increase 5
        ;;
      "down")
        pamixer --decrease 5
        ;;
      "mute")
        pamixer --toggle-mute
        ;;
    esac
  else
    vol=$(pamixer --get-volume)
    muted=$(pamixer --get-mute)

    if [[ "''${muted}" == "true" ]]; then
      echo "󰸈 ''${vol}% (m)"
    elif [[ ''${vol} -lt 33 ]]; then
      echo "󰕿 ''${vol}%"
    elif [[ ''${vol} -lt 66 ]]; then
      echo "󰖀 ''${vol}%"
    else
      echo "󰕾 ''${vol}%"
    fi
  fi
  '';
}
