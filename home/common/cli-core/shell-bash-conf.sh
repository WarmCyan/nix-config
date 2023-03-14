# ==================================================
# BASH SPECIFIC STUFF (interactive shell)
# ==================================================

# prepare colors
# NOTE: the \001 and \002 are from https://unix.stackexchange.com/a/447520
# without, the bash line doesn't wrap correctly
readonly ta_none="\001$(tput sgr0 2> /dev/null || true)\002"
readonly ta_bold="\001$(tput bold 2> /dev/null || true)\002"
readonly fg_blue="\001$(tput setaf 4 2> /dev/null || true)\002"
    
# nice prompt
PS1="[${fg_blue}\t${ta_none}] ${fg_blue}\u${ta_normal}@${fg_blue}${ta_bold}\h${ta_none}${fg_blue} \w${ta_none} $ " 


# if we have a quick and dirty bashrc addition:
[[ -f ${HOME}/.bashrc_local ]] && . "${HOME}/.bashrc_local"
