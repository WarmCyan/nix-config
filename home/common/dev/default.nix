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
    # NOTE: commented out because it's somehow bringing in nix 2.15.3 as
    # a dependency??
    #rnix-lsp    # nix language server
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
    export MAMBA_ROOT_PREFIX="''${HOME}/micromamba";
    __mamba_setup="$('${pkgs.micromamba}/bin/micromamba' shell hook --shell zsh --prefix "''${HOME}/micromamba" 2> /dev/null)"
    if [ $? -eq 0 ]; then 
        eval "$__mamba_setup"
    else
        if [ -f "''${HOME}/micromamba/etc/profile.d/micromamba.sh" ]; then
            . "''${HOME}/micromamba/etc/profile.d/micromamba.sh"
        else
            export  PATH="''${HOME}/micromamba/bin:$PATH"
        fi
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<

    # NOTE: Needed because of the change in 1.2.0: https://github.com/mamba-org/mamba/pull/2137/files
    # for whatever reason though __mamba_exe doesn't seem to exist? I determined
    # that manually making a function for it that just calls $MAMBA_EXE (like
    # what the completion used to do) seems to work fine though:
    __mamba_exe () {
      $MAMBA_EXE "$@"
    }
  '';
  
  programs.bash.initExtra = /* sh */ ''
    # >>> mamba initialize >>>
    export MAMBA_EXE='${pkgs.micromamba}/bin/micromamba';
    export MAMBA_ROOT_PREFIX="''${HOME}/micromamba";
    __mamba_setup="$('${pkgs.micromamba}/bin/micromamba' shell hook --shell bash --prefix "''${HOME}/micromamba" 2> /dev/null)"
    if [ $? -eq 0 ]; then 
        eval "$__mamba_setup"
    else
        if [ -f "''${HOME}/micromamba/etc/profile.d/micromamba.sh" ]; then
            . "''${HOME}/micromamba/etc/profile.d/micromamba.sh"
        else
            export  PATH="''${HOME}/micromamba/bin:$PATH"
        fi
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
    
    # NOTE: Needed because of the change in 1.2.0: https://github.com/mamba-org/mamba/pull/2137/files
    # for whatever reason though __mamba_exe doesn't seem to exist? I determined
    # that manually making a function for it that just calls $MAMBA_EXE (like
    # what the completion used to do) seems to work fine though:
    __mamba_exe () {
      $MAMBA_EXE "$@"
    }
  '';
}
