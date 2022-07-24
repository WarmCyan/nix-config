# ==================================================
# COMMON SHELL CAPABILITIES (interactive shell)
# ==================================================

# every time we change directories, ls, because I always do that anyway.
function cd {
    builtin cd "$@" && ls -F
}

# allow running scripts in current directory without needing ./
export PATH=.:$PATH

# import additional files if we have them

# if we have any quick and dirty path additions, place here
[[ -f ${HOME}/.shell_additional_path ]] && . "${HOME}/.shell_additional_path"
# if we have a fun homescreen like printing a logo, that can go here :)
[[ -f ${HOME}/.home ]] && . "${HOME}/.home"
