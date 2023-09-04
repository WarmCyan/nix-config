# Function to initialize color variables, primarily thanks to https://github.com/ralish/bash-script-template/blob/main/template.sh
# SC2120 - color_init will work even if we don't pass args to it, so ignore this
# SC2034 - the entire point of this function is to define vars for _other_
#   functions to use, so disregard
# shellcheck disable=SC2034,SC2155,SC2120
function color_init () {
  # if a nonblank variable (nocolor) is passed in, we set the attributes to be blank.
  # Note that "The output of the $ta_none variable after each tput is redundant 
  # during normal execution, but ensures the terminal output isn't mangled when 
  # running with xtrace."
  readonly ta_none="$(tput sgr0 2> /dev/null || true)"
  
  # https://stackoverflow.com/questions/18096670/what-does-z-mean-in-bash
  if [[ -z ${1-} ]]; then
    # Text attributes
    readonly ta_bold="$(tput bold 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_uscore="$(tput smul 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_blink="$(tput blink 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_reverse="$(tput rev 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly ta_conceal="$(tput invis 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # Foreground codes
    readonly fg_black="$(tput setaf 0 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_blue="$(tput setaf 4 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_cyan="$(tput setaf 6 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_green="$(tput setaf 2 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_magenta="$(tput setaf 5 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_red="$(tput setaf 1 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_white="$(tput setaf 7 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly fg_yellow="$(tput setaf 3 2> /dev/null || true)"
    printf '%b' "$ta_none"

    # Background codes
    readonly bg_black="$(tput setab 0 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_blue="$(tput setab 4 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_cyan="$(tput setab 6 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_green="$(tput setab 2 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_magenta="$(tput setab 5 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_red="$(tput setab 1 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_white="$(tput setab 7 2> /dev/null || true)"
    printf '%b' "$ta_none"
    readonly bg_yellow="$(tput setab 3 2> /dev/null || true)"
    printf '%b' "$ta_none"
else
    # Text attributes
    readonly ta_bold=''
    readonly ta_uscore=''
    readonly ta_blink=''
    readonly ta_reverse=''
    readonly ta_conceal=''

    # Foreground codes
    readonly fg_black=''
    readonly fg_blue=''
    readonly fg_cyan=''
    readonly fg_green=''
    readonly fg_magenta=''
    readonly fg_red=''
    readonly fg_white=''
    readonly fg_yellow=''

    # Background codes
    readonly bg_black=''
    readonly bg_blue=''
    readonly bg_cyan=''
    readonly bg_green=''
    readonly bg_magenta=''
    readonly bg_red=''
    readonly bg_white=''
    readonly bg_yellow=''
  fi
}
