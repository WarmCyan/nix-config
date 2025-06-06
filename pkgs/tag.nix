# DONE: ability to list things in multiple tags
# DONE: ability to handle stdin list

{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "tag";
  version = "0.2.0";
  description = "A file tagging tool for a file system based on hardlinking files into tag folders";
  usage = "tag [-r|--remove] [-f|--find] [-d|--display] {FILE} {TAG1} {TAG2} ...\n\nExamples:\n\ttag \t\t\t\t# lists all files in current dir with their tags\n\ttag myfile.txt doc important\t# adds doc and important tags to myfile.txt\n\ttag -r myfile.txt doc\t\t# removes doc tag from myfile.txt\n\ttag -d somedir\t\t\t# lists all files in somedir with their tags\n\ttag -l tag1 tag2\t\t# lists all files with both tag1 and tag2\n\nNotes:\n- Tags directory is ~/tags by default, or uses TAG_DIR env var\n- When using --find, by default will search through all files in ~, root dir for search controlled by TAG_SEARCH_SOURCE env var.\n- Suggested alias: alias tags='tag -d'\n- Suggested alias: alias taglist='tag -t'\n- Suggested alias: alias tag-ls='tag -l'";
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
    display = {
      flags = [ "-d" "--display"];
      description = "List files in current (or specified) directory and display their tags. Equivalent to running tag with no arguments.";
      option = true;
    };
    list = {
      flags = [ "-l" "--list"];
      description = "List all files that have all of the specified tags.";
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
    function display_files_with_tags() {
      target_dir="''${1-.}"
      # https://askubuntu.com/questions/344407/how-to-read-complete-line-in-for-loop-with-spaces
      IFS=$'\n'
      #for line in $(ls -lip "''${target_dir}" | tail --lines=+2 | tr -s ' '); do
      # SC2012 - they're recommending find instead of ls, ls is fine
      #shellcheck disable=SC2012
      for line in $(ls -lip "''${target_dir}" | tr -s ' ' | sed -e 's/^ //'); do
        # tr -s ' ' replaces multiple spaces with single space so formatting doesn't
        # screw up cut
        filename=$(echo "''${line}" | cut -d ' ' -f10)
        inode=$(echo "''${line}" | cut -d ' ' -f1)
        # unfortunately since we removed the tail, for a listing with more than
        # one file there's a "total" line at the top, so we just hackily deal
        # with that here
        if [[ "''${inode}" == "total" ]]; then
          continue
        fi
        tag_list=$(find "''${tags_dir}" -inum "''${inode}" | cut -c''${tags_dir_len}- | sed -r -e "s/([a-zA-Z0-9\-\_\/]*)\/[a-zA-Z0-9\-\_\.]+/\1/g")
        echo -e "''${filename} ''${fg_blue}''${tag_list}''${ta_none}" | tr '\n' ' '
        echo ""
      done
    }
    # support reading filepaths from stdin 
    function display_files_with_tags_stdin_wrapper() {
      # check if stdin is not open on the terminal (meaning pipe is incoming?)
      if test ! -t 0; then
        while read -r filepath_target; do
          display_files_with_tags "''${filepath_target}" "$@"
        done
      else
        # no stdin pipe, assume file is passed
        display_files_with_tags "$@"
      fi
    }


    # list all files that have the specified set of tags (tag intersection)
    function list_tag_files() {
      tag="''${1}"
      #shellcheck disable=SC2012
      working_tag_ls=$(ls "''${tags_dir}/''${tag}" | sort)
      shift
      while [ $# -gt 0 ]; do
        tag="''${1}"
        #shellcheck disable=SC2012
        working_tag_ls=$(echo "''${working_tag_ls}" | comm -12 - <(ls "''${tags_dir}/''${tag}" | sort))
        shift
      done
      echo "''${working_tag_ls}"
    }

    # link the passed file into each specified tag directory
    function add_tags_to_file() {
      file="''${1}"
      shift
      while [ $# -gt 0 ]; do
        tag="''${1}"
        mkdir -p "''${tags_dir}/''${tag}"
        ln "''${file}" "''${tags_dir}/''${tag}"
        shift
      done
    }
    # support reading filepaths from stdin 
    function add_tags_to_file_stdin_wrapper() {
      # check if stdin is not open on the terminal (meaning pipe is incoming?)
      if test ! -t 0; then
        while read -r filepath; do
          add_tags_to_file "''${filepath}" "$@"
        done
      else
        # no stdin pipe, assume file is passed
        add_tags_to_file "$@"
      fi
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
    # support reading filepaths from stdin 
    function remove_tags_from_file_stdin_wrapper() {
      # check if stdin is not open on the terminal (meaning pipe is incoming?)
      if test ! -t 0; then
        while read -r filepath; do
          remove_tags_from_file "''${filepath}" "$@"
        done
      else
        # no stdin pipe, assume file is passed
        remove_tags_from_file "$@"
      fi
    }

    # search system for each file with same inode as file specified
    function find_file_pointers() {
      file="''${1}"
      #shellcheck disable=SC2012
      inode=$(ls -li "''${file}" | cut -d ' ' -f1)
      find "''${search_source_dir}" -inum "''${inode}" 2>/dev/null
    }

    function tag_list() {
      ls -1 "''${tags_dir}"
    }

    # ensure the tags directory exists
    if [ ! -d "''${tags_dir}" ]; then
      mkdir -p "''${tags_dir}"
    fi

    # run correct subtask based on flags
    if [[ ''${find-false} == true ]]; then
      find_file_pointers "$@"
    elif [[ ''${remove-false} == true ]]; then
      remove_tags_from_file_stdin_wrapper "$@"
    elif [[ ''${list-false} == true ]]; then
      list_tag_files "$@"
    elif [[ ''${display-false} == true ]]; then
      display_files_with_tags_stdin_wrapper "$@"
    elif [[ ''${taglist-false} == true ]]; then
      tag_list
    elif [ $# -gt 0 ]; then
      add_tags_to_file_stdin_wrapper "$@"
    else
      display_files_with_tags_stdin_wrapper
    fi
  '';
}
