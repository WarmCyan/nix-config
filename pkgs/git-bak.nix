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
      description = "A username for which to download all repos.";
    };
    token_file = {
      flags = [ "-t" "--token" ];
      description = "Path to a file containing github API token to use for the provided username for getting private repos. If specified without --username, will grab all of token's associated user's repos. Create token as fine grained token with metadata permissions.";
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
    sleep .5  # don't spam api
  }

  if [[ $# -eq 0 ]]; then
    echo "Please specify output directory."
    exit 1
  else
    output_dir="$1"
  fi

  # echo "additional: ''${additional-}, user: ''${user-}, token: ''${token_file-}"

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
      # shellcheck disable=SC2086,SC2089
      auth_str="Authorization: Bearer $(cat ''${token_file})"
    fi

    # shellcheck disable=SC2090,2086
    for repo in $(curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "''${auth_str}" "https://api.github.com/users/''${user}/repos?per_page=100" | jq -r '.[].ssh_url'); do
      collect_repo "''${repo}"
    done
    exit 0
  fi
  
  # if only a token file is provided, assumed to want to retrieve personal
  # private repos
  if [[ "''${token_file-}" != "" ]]; then
    # shellcheck disable=SC2086,SC2089
    auth_str="Authorization: Bearer $(cat ''${token_file})"
    
    # shellcheck disable=SC2090,2086
    for repo in $(curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" -H "''${auth_str}" "https://api.github.com/user/repos?per_page=100" | jq -r '.[].ssh_url'); do
      collect_repo "''${repo}"
    done
    exit 0
  fi
  '';
}
