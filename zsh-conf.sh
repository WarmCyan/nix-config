# ==================================================
# ZSH SPECIFIC STUFF
# ==================================================

RPROMPT='[%D{%L:%M:%S %p}]'

# https://stackoverflow.com/questions/12580675/zsh-preexec-command-modification
function update_rprompt_with_date {
    zle reset-prompt
    zle accept-line
}
zle -N update_rprompt_with_date
bindkey '^J' update_rprompt_with_date
bindkey '^M' update_rprompt_with_date

# if we have a quick and dirty zshrc addition:
[[ -f ${HOME}/.zshrc_local ]] && . "${HOME}/.zshrc_local"
