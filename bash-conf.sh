# ==================================================
# BASH SPECIFIC STUFF (interactive shell)
# ==================================================

# prepare colors
readonly ta_none="$(tput sgr0 2> /dev/null || true)"
readonly ta_bold="$(tput bold 2> /dev/null || true)"
readonly fg_blue="$(tput setaf 4 2> /dev/null || true)"
    
# nice prompt
PS1="[${fg_blue}\t${ta_none}] ${fg_blue}\u${ta_normal}@${fg_blue}${ta_bold}\h${ta_none}${fg_blue} \w${ta_none} $ " 


# if we have a quick and dirty bashrc addition:
[[ -f ${HOME}/.bashrc_local ]] && . "${HOME}/.bashrc_local"
