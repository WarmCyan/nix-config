# TODO: put in juptyer configuration files

{ pkgs, username, ... }:
let
  inherit (builtins) readFile;
in
{
  home.packages = with pkgs; [
    # -- Shell scripting tools --
    shellcheck  # static analysis/linter(?) for bash/sh
    shfmt       # shell script formatter

    # -- Nix tools --
    rnix-lsp    # nix language server
    nixfmt      # nix formatter
    deadnix     # nix dead code locator (no idea what this is)
    statix      # nix linter

    pre-commit  # we want this separately so we can apply even to non-python projects
    micromamba  # python environment management

    # -- MY tools! --
    add-jupyter-env # run inside a conda env to add jupyter lab setup
    sri-hash        # quick nix utility to grab the sri from a github repo
  ];

  # TODO: put in fancier vim plugins stuff

  # ==========================================
  # Set up micromamba
  # ==========================================

  home.file.".mambarc".text = ''
   channels:
   - conda-forge
  '';

  programs.zsh.initExtra = /* sh */ ''
    # >>> mamba initialize >>>
    export MAMBA_EXE='${pkgs.micromamba}/bin/micromamba';
    export MAMBA_ROOT_PREFIX='/home/${username}/micromamba';
    __mamba_setup="$('${pkgs.micromamba}/bin/micromamba' shell hook --shell zsh --prefix '/home/${username}/micromamba' 2> /dev/null)"
    if [ $? -eq 0 ]; then 
        eval "$__mamba_setup"
    else
        if [ -f "/home/${username}/micromamba/etc/profile.d/micromamba.sh" ]; then
            . "/home/${username}/micromamba/etc/profile.d/micromamba.sh"
        else
            export  PATH="/home/${username}/micromamba/bin:$PATH"
        fi
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
  '';
  
  programs.bash.initExtra = /* sh */ ''
    # >>> mamba initialize >>>
    export MAMBA_EXE='${pkgs.micromamba}/bin/micromamba';
    export MAMBA_ROOT_PREFIX='/home/${username}/micromamba';
    __mamba_setup="$('${pkgs.micromamba}/bin/micromamba' shell hook --shell bash --prefix '/home/${username}/micromamba' 2> /dev/null)"
    if [ $? -eq 0 ]; then 
        eval "$__mamba_setup"
    else
        if [ -f "/home/${username}/micromamba/etc/profile.d/micromamba.sh" ]; then
            . "/home/${username}/micromamba/etc/profile.d/micromamba.sh"
        else
            export  PATH="/home/${username}/micromamba/bin:$PATH"
        fi
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
  '';
}
