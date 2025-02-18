# TODO: can't break out of env loop if env already activated
{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "cg";
  version = "0.1.0";
  description = "code grep - tool to search micromamba env site package code.";
  usage = "cg [-h|--help] [--version]";
  runtimeInputs = [
    pkgs.ripgrep
    pkgs.fzf
    pkgs.bat
  ];
  exitOnError = false;
  text = /* bash */ ''

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
            continue_search=1


            # shellcheck disable=SC2181
            while [ $continue_search -eq 1 ]
            do
              echo "''${lib_path}"
              # shellcheck disable=SC2164
              cd "''${env_loc}/lib/''${lib_path}"
              file_line="$(rg --column --color=always --line-number --no-heading --smart-case . | fzf --ansi --delimiter=: --preview='bat --color=always {1} --highlight-line {2}' --preview-window '+{2}-2,~3' )"

              # shellcheck disable=SC2181
              if [ $? -ne 0 ]; then
                continue_search=0
              else
                echo "''${file_line}"
                
                file_path="''${env_loc}/lib/''${lib_path}/$(echo ''\"''${file_line}''\" | cut -d : -f 1)"
                lineno="$(echo ''\"''${file_line}''\" | cut -d : -f 2)"
                echo "''${file_path}"

                nvim "''${file_path}" "+''${lineno}"
              
              fi

          done
          fi

          
        done
        
      fi
    done
  '';
}
