# original: https://github.com/WildfireXIII/session-notes-manager/blob/master/notes

# TODO: a flag to just print the contents of the log with the given name to stdout
# (this could be used to create "watch engilog --read my_log | rg "TODO" and so
# on.)
# TODO: a flag to list the logs to stdout
# TODO: it would be cool if we could have nvim open the log and set the working
# directory to a project directory that's listed at the top of the file.
  # NOTE: in order for this to work, you'd have to allow specifying multiple 
  # directories, where you list them per hostname (so engilog would have to
  # handle this based on what the current hostname was)
# TODO: so yeah, the engineering log needs to have some metadata at the top
# TODO: there should also be some syntax to allow exporting specifically
# indicated sections (e.g. allow it to be a decision log as well. and allow
# listing those out and exporting each one to a file perhaps)

# TODO: add in git repo initial handling


# IDEA: syntax for file that allows "injecting" todos into the top of the file

# where am I going to keep the notes? What is convention?
# probably need to do same as iris and use $XDG_DATA_HOME-$HOME/.local/share


{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "engilog";
  version = "0.1.0";
  description = "Tool for keeping engineering logs - off the cuff notes, decisions, and brain context while working.";
  usage = "engilog [-h|--help] [--version]";
  initColors = true;
  parameters = {};
  runtimeInputs = [
    pkgs.git
  ];
  text = /* bash */ ''
    # references array
    declare -a references_single=("a" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "o" "r" "s" "t" "u" "v" "w" "x")
    declare -a references_double=("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "z")

    declare -A references=()

    # TODO: what is?
    nextref=""
    
    notes_dir="''${XDG_DATA_HOME-$HOME/.local/share}/engilog"

    # sync git
    # TODO: don't we need to check if it's even a git repo first?
    # TODO: don't we need to ask if we want to clone existing notes if not? (see
    # the install script.)
    echo "Syncing notes..."
    pushd "''${notes_dir}" &>/dev/null
    git pull
    popd
    
    
    function insert_time
    {
      date_time_string=`date +'%Y.%m.%d %H:%M:%S'`
      echo -e "\n----- ''${date_time_string} -----\n" >> "''$1"
    }

    function edit_file
    {
      nvim "+ normal Go" "''$1"
    }

    echo -e "Press 'n' to create a new notes session, or the key combo in yellow below to open a previous session"
    
    double_needed=false
    count=`ls ''${notes_dir} -1q | wc -l`

    if [ ''$count -gt ''${#references_single[@]} ]; then
      double_needed=true
    fi
    
    # iterate through each filename, print it out and store reference characters with it
    pushd "''${notes_dir}" &>/dev/null
    index=0
    subindex=0
    for filename in `ls -t1q`; do
      coloredname=`sed -E "s/(.*)_(.*)_(.*)/$(printf "''${fg_blue}''${ta_bold}")\1$(printf "''${ta_none}")\_\2\_\3/g" <<< "''${filename}"`

      nextref=""
      
      if [ "''${double_needed}" = 'true' ]; then
        nextref="''${references_single[''$index]}''${references_double[''$subindex]}"
        if [[ "''${subindex}" -ge "''${#references_double[@]}" ]]; then
          subindex=0
          index=''$index+1
        else
          subindex=''$subindex+1
        fi
      else
        nextref="''${references_single[''$index]}"
        index=''$index+1
      fi
      
      references+=(["''$nextref"]="''$filename")
      echo -e "''${fg_yellow}''${ta_bold}''${nextref} ''${ta_none}''${coloredname}"
    done
    popd &>/dev/null

    # get user input
    read -p "Input: " -rn1 char1 
    if [[ "''${char1}" == "n" ]]; then
      echo -e "\nCreating a new notes session"
      
      read -p "Session name: " name
      echo "''${name}"

      datestring=`date +"%Y.%m.%d"`

      filename="''${name}_''${HOSTNAME}_''${datestring}"
      echo "''${filename}"
      touch "''${notes_dir}/''${filename}"
      
      inserttime "''${notesfolder}/''${filename}"
      
      editfile "''${notesfolder}/''${filename}"
      
      # sync git stuff
      echo "Syncing notes..."
      pushd ''${notes_dir} &>/dev/null
      git add -A 
      git commit -am "Added ''${filename}"
      git push
      popd
    else 
      reference_string="''${char1}"
      
      if [ "''${double_needed}" = 'true' ]; then
        read -rn1 char2
        reference_string="''${char1}''${char2}"
      fi
        
      filename=''${references[''$reference_string]}
      echo -e "\nOpening ''${filename}..."
      inserttime "''${notes_dir}/''${filename}"
      editfile "''${notes_dir}/''${filename}"
      
      # sync git stuff
      echo "Syncing notes..."
      pushd ''${notes_dir} &>/dev/null
      git commit -am "Edited ''${filename}"
      git push
      popd
    fi
  '';
}
