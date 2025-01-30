# ==================================================
# ZSH SPECIFIC STUFF (interactive shell)
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

# assumes agnoster theme, see
# https://github.com/agnoster/agnoster-zsh-theme/issues/30
prompt_color="blue"
function prompt {
  export prompt_color="blue"

  if [[ $# -gt 0 ]]; then
    case "$1" in
      "blue")
        export prompt_color="blue"
      ;;
      "cyan")
        export prompt_color="cyan"
      ;;
      "green")
        export prompt_color="green"
      ;;
      "magenta")
        export prompt_color="magenta"
      ;;
      "red")
        export prompt_color="red"
      ;;
      "orange")
        export prompt_color="yellow"
      ;;
    esac
  fi
}

prompt_dir() {
  prompt_segment "${prompt_color}" "${CURRENT_FG}" '%~'
}

# if we have a quick and dirty zshrc addition:
[[ -f ${HOME}/.zshrc_local ]] && . "${HOME}/.zshrc_local"
