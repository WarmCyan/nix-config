{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "td-state";
  version = "0.1.1";
  description = "Takes a given todo-style text line and changes or cycles the todo state";
  usage = "td-state ITEM [todo|strt|wait|done|canc|bug|fixd]\nLeave state out in order to cycle.";
  parameters = {};
  runtimeInputs = [ pkgs.coreutils ];
  text = /* bash */ ''
  # ignore 2001 because I'm doing complicated substitutions, see https://www.shellcheck.net/wiki/SC2001
  # shellcheck disable=SC2001
  function change_state {
    # if no state included, this isn't a todo line, leave alone
    if echo "$1" | grep -q "TODO:" || 
      echo "$1" | grep -q "STRT:" ||
      echo "$1" | grep -q "WAIT:" || 
      echo "$1" | grep -q "DONE:" ||
      echo "$1" | grep -q "CANC:" || 
      echo "$1" | grep -q "BUG:" || 
      echo "$1" | grep -q "FIXD:"; then
      # item=$(echo $1 | sed "s/^.\{6\}//") # TODO: if we want to also support w comments, use groups to get only everything after 4 cp letters and colon etc.
      current_state=$(echo "$1" | grep -o "\(TODO\|STRT\|WAIT\|DONE\|CANC\|BUG\|FIXD\)") 
      item=$(echo "$1" | sed -E "s/^(.*)(TODO|STRT|WAIT|DONE|CANC|BUG|FIXD):\ (.*)$/\3/")
      pre=$(echo "$1" | sed -E "s/^(.*)(TODO|STRT|WAIT|DONE|CANC|BUG|FIXD):\ (.*)$/\1/")

      shift
      new_state="''${1:-cycle}"

      # convert to uppercase
      new_state=$(echo "''${new_state}" | tr "[:lower:]" "[:upper:]")

      if [[ "''${new_state}" == "CYCLE" ]]; then
        case "''${current_state}" in
          TODO)
            new_state="STRT"
            ;;
          STRT)
            new_state="DONE"
            ;;
          DONE)
            new_state="WAIT"
            ;;
          WAIT)
            new_state="CANC"
            ;;
          CANC)
            new_state="TODO"
            ;;
          BUG)
            new_state="FIXD"
            ;;
          FIXD)
            new_state="BUG"
            ;;
          *)
            echo "Invalid state given"
            ;;
        esac
      fi

      echo "''${pre}''${new_state}: ''${item}"
    else
      echo "$1"
    fi
  }

  # https://stackoverflow.com/questions/19408649/pipe-input-into-a-script
  if [ -p /dev/stdin ]; then
    while IFS= read -r line; do
      change_state "''${line}" "$@"
    done
  else
    if [[ "$#" -lt 1 ]]; then
      print_help
      exit
    fi
    change_state "$1" "''${@:2}"
  fi
  '';
}
