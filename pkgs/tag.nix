{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "tag";
  version = "0.1.0";
  description = "A file tagging tool for a file system based on hardlinking files into tag folders";
  usage = "tag {FILE} {TAG1} {TAG2} ...\n\nExamples:\n\ttag \t\t\t\t# lists all files in current dir with their tags\n\ttag myfile.txt doc important\t# adds doc and important tags to myfile.txt\n\ttag -r myfile.txt doc\t\t# removes doc tag from myfile.txt\n\ttag -l somedir\t\t\t# lists all files in somedir with their tags";
  initColors = true;
  parameters = {
    find = {
      flags = [ "-f" "--find" ];
      description = "Find all files in the filesystem that point to this file. WARNING: potentially slow. Based on TAG_SEARCH_SOURCE env var.";
      option = true;
    };
    remove = {
      flags = [ "-r" "--remove" ];
      description = "Remove the specified tags from the file rather than add. Specify no tags to remove all.";
      option = true;
    };
    list = {
      flags = [ "-l" "--list"];
      description = "List files in current (or specified) directory and show their tags. Equivalent to running tag with no arguments.";
      option = true;
    };
    taglist = {
      flags = [ "-t" "--tag-list" ];
      description = "";
      option = true;
    };
  };
  text = /* bash */ ''

    tags_dir="''${TAG_DIR-$HOME/tags}"
    search_source_dir="''${TAG_SEARCH_SOURCE-$HOME}"

    # used to help remove tags dir prefix from tag folder names
    tags_dir_len=''${#tags_dir}
    ((tags_dir_len+=2))

    # a soft ls equivalent that prints the set of tags for all files in current dir
    function list_files_with_tags() {
      target_dir="''${1-.}"
      # https://askubuntu.com/questions/344407/how-to-read-complete-line-in-for-loop-with-spaces
      IFS=$'\n'
      #shellcheck disable=SC2012
      for line in $(ls -li "''${target_dir}" | tail --lines=+2 | tr -s ' '); do
        # tr -s ' ' replaces multiple spaces with single space so formatting doesn't
        # screw up cut
        filename=$(echo "''${line}" | cut -d ' ' -f10)
        inode=$(echo "''${line}" | cut -d ' ' -f1)
        tag_list=$(find "''${tags_dir}" -inum "''${inode}" | cut -c''${tags_dir_len}- | sed -r -e "s/([a-zA-Z0-9\-\_\/]*)\/[a-zA-Z0-9\-\_\.]+/\1/g")
        echo -e "''${filename} ''${fg_blue}''${tag_list}''${ta_none}" | tr '\n' ' '
        echo ""
      done
    }

    # link the passed file into each specified tag directory
    function add_tags_to_file() {
      file="''${1}"
      shift
      while [ $# -gt 0 ]; do
        tag="''${1}"
        mkdir -p "''${tags_dir}/''${tag}"
        ln -t "''${tags_dir}/''${tag}" "''${file}"
        shift
      done
    }

    function remove_tags_from_file() {
      file="''${1}"
      #shellcheck disable=SC2012
      inode=$(ls -li "''${file}" | cut -d ' ' -f1)
      shift

      # special handling for if no additional args - remove all tags
      if [ $# -eq 0 ]; then
        find "''${tags_dir}" -inum "''${inode}" -print0 | xargs -I '{}' -0 unlink '{}'
      else
        while [ $# -gt 0 ]; do
          tag="''${1}"
          find "''${tags_dir}/''${tag}" -inum "''${inode}" -print0 | xargs -I '{}' -0 unlink '{}'
          shift
        done
      fi
    }

    # search system for each file with same inode as file specified
    function find_file_pointers() {
      file="''${1}"
      #shellcheck disable=SC2012
      inode=$(ls -li "''${file}" | cut -d ' ' -f1)
      find "''${search_source_dir}" -inum "''${inode}"
    }

    function tag_list() {
      ls -1 "''${tags_dir}"
    }

    if [[ ''${find-false} == true ]]; then
      find_file_pointers "$@"
    elif [[ ''${remove-false} == true ]]; then
      remove_tags_from_file "$@"
    elif [[ ''${list-false} == true ]]; then
      list_files_with_tags "$@"
    elif [[ ''${taglist-false} == true ]]; then
      tag_list
    elif [ $# -gt 0 ]; then
      add_tags_to_file "$@"
    else
      list_files_with_tags
    fi
  '';
}
