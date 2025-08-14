# TODO: tmux integration w custom tmux
# TODO: can't break out of env loop if env already activated
# TODO: modify both query line and tmux window title (if relevant)
# TODO: specify whether to check conda env or some configed folder of git repos
{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "cg";
  version = "0.2.0";
  description = "code grep - tool to search micromamba env site package code.";
  usage = "cg [-t|--tmux] [-h|--help] [--version] [CODE_FOLDER_PATH]";
  parameters = {
    tmux = {
      flags = [ "-t" "--tmux" ];
      description = "Entering on target line of code opens the file in a new tmux window instead of replacing current.";
      option = true;
    };
  };
  runtimeInputs = [
    pkgs.ripgrep
    pkgs.fzf
    pkgs.bat
  ];
  exitOnError = false;
  text = /* bash */ ''

    function search_within_folder() {
      folder_path="''${1}"
      continue_search=1

      folder_name="$(echo ''\"''${folder_path}''\" | sed -e 's/.*\/\([A-Za-z0-9\-\_]*\)$/\1/g')"
      echo -e "\033]0;''${folder_name}\007"  # set terminal title
    
      while [ $continue_search -eq 1 ]; do
        echo "''${folder_path}"

        # shellcheck disable=SC2164
        pushd "''${folder_path}"
        file_line="$(rg --column --color=always --line-number --no-heading --smart-case . | fzf --ansi --delimiter=: --preview='bat --color=always {1} --highlight-line {2}' --preview-window '+{2}-2,~3' --prompt=''\"''${folder_name}> ''\")"

        # shellcheck disable=SC2181
        if [ $? -ne 0 ]; then
          continue_search=0
        else
          echo "''${file_line}"

          # file_path="''${folder_path}/$(echo ''\"''${file_line}''\" | cut -d : -f 1)"
          file_path="$(echo ''\"''${file_line}''\" | cut -d : -f 1)"
          lineno="$(echo ''\"''${file_line}''\" | cut -d : -f 2)"
          echo "Opening ''${file_path}"

          if [[ ''${tmux-false} == true ]]; then
            tmux new-window -n "''${file_path}" "nvim \"''${file_path}\" \"+''${lineno}\""
          else
            nvim "''${file_path}" "+''${lineno}"
          fi
        fi
        popd || exit
      done
    }

    # direct path to code directory specified
    if [[ $# -gt 0 ]]; then
      search_within_folder "$1"
      exit 0
    fi

    # otherwise allow searching through conda/mamba environments
    continue_env=1
    continue_lib=1
    continue_search=1

    while [ $continue_env -eq 1 ]
    do
  
      env_loc="''${CONDA_PREFIX-$(micromamba env list | fzf | sed -e 's/\s*[A-Za-z0-9\-\_]*\s*\(\/[\/A-Za-z0-9\-\_]*\)\s*/\1/g')}"

      # shellcheck disable=SC2181
      if [ $? -ne 0 ]; then
        continue_env=0
      else
        continue_lib=1


        # shellcheck disable=SC2181
        while [ $continue_lib -eq 1 ]
        do
          echo "''${env_loc}"
          # shellcheck disable=SC2164
          cd "''${env_loc}/lib"
          lib_path="$(rg --sort-files --null --files python3.*/site-packages/* --max-depth=1 -g '!**/*.dist-info/**' | xargs -0 dirname | uniq | fzf)"

          # shellcheck disable=SC2181
          if [ $? -ne 0 ]; then
            continue_lib=0
          else
            search_within_folder "''${env_loc}/lib/''${lib_path}"
          fi
        done
      fi
    done
  '';
}
