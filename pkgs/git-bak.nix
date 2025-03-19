{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "git-bak";
  version = "0.1.0";
  description = "Repository backup tool";
  usage = "git-bak [-l additional_repos.txt] [-u username] [-t token_file] backup_dir";
  parameters = {
    additional = {
      flags = [ "-l" "--list-file" ];
      description = "A path to a text file where each line is a URL to clone/backup";
    };
    user = {
      flags = [ "-u" "--username" ];
      description = "A username for which to download all repos. If a token file is included and this is your user it will also grab private repos.";
    };
    token_file = {
      flags = [ "-t" "--token" ];
      description = "Path to a file containing github API token to use for the provided username for getting private repos.";
    };
  };
  runtimeInputs = [
    pkgs.jq
  ];
  text = /* bash */ ''

  function collect_repo () {
    repo_url="$1"
    repo_name=$(echo "''${repo_url}" | sed -e "s/.*\/\(.*\)$/\1/")
    echo "Collecting ''${repo_name} from ''${repo_url}..."
    git -C "''${output_dir}/''${repo_name}" pull || git clone "''${repo_url}" "''${output_dir}/''${repo_name}"
  }

  if [[ $# -eq 0 ]]; then
    echo "Please specify output directory."
    exit 1
  else
    output_dir="$1"
  fi
  
  if [[ "''${additional-}" != "" ]]; then
    # shellcheck disable=SC2013
    for url in $(cat "''${additional}"); do
      collect_repo "''${url}"
    done
  fi

  if [[ "''${user-}" != "" ]]; then
    if [[ "''${token_file-}" == "" ]]; then
      echo "NOTE: specify a token file in order to get your own private repositories"
      auth_str=""
    else
      # shellcheck disable=SC2086
      auth_str="-H \"Authorization: Bearer $(cat ''${token_file})\""
    fi
    echo "''${auth_str}"

    curl ''${auth_str} https://api.github.com/search/repositories?q=user:''${user} | jq '.items.[].ssh_url'
  fi
  '';
}
