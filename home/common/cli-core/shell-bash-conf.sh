# ==================================================
# BASH SPECIFIC STUFF (interactive shell)
# ==================================================

# prepare colors
# NOTE: the \001 and \002 are from https://unix.stackexchange.com/a/447520
# without, the bash line doesn't wrap correctly
readonly ta_none="\001$(tput sgr0 2> /dev/null || true)\002"
readonly ta_bold="\001$(tput bold 2> /dev/null || true)\002"
readonly fg_blue="\001$(tput setaf 4 2> /dev/null || true)\002"
readonly fg_cyan="\001$(tput setaf 6 2> /dev/null || true)\002"
readonly fg_green="\001$(tput setaf 2 2> /dev/null || true)\002"
readonly fg_magenta="\001$(tput setaf 5 2> /dev/null || true)\002"
readonly fg_red="\001$(tput setaf 1 2> /dev/null || true)\002"
readonly fg_orange="\001$(tput setaf 3 2> /dev/null || true)\002"

function prompt {
  export prompt_color="${fg_blue}"

  if [[ $# -gt 0 ]]; then
    case "$1" in
      "blue")
        export prompt_color="${fg_blue}"
      ;;
      "cyan")
        export prompt_color="${fg_cyan}"
      ;;
      "green")
        export prompt_color="${fg_green}"
      ;;
      "magenta")
        export prompt_color="${fg_magenta}"
      ;;
      "red")
        export prompt_color="${fg_red}"
      ;;
      "orange")
        export prompt_color="${fg_orange}"
      ;;
    esac
  fi
  export PS1="[${prompt_color}\t${ta_none}] ${prompt_color}\u${ta_normal}@${prompt_color}${ta_bold}\h${ta_none}${prompt_color} \w${ta_none} $ "
}

# nice prompt
#PS1="[${fg_blue}\t${ta_none}] ${fg_blue}\u${ta_normal}@${fg_blue}${ta_bold}\h${ta_none}${fg_blue} \w${ta_none} $ " 
prompt "blue"


# if we have a quick and dirty bashrc addition:
[[ -f ${HOME}/.bashrc_local ]] && . "${HOME}/.bashrc_local"
