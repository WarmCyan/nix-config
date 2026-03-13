# TODO: put in juptyer configuration files

{ pkgs, username, config, lib, ... }:
let
  inherit (builtins) readFile;


  jupyterThemeSettings = {
    theme = "JupyterLab Dark";
    "theme-scrollbars" = true;
  };

  jupyterExtensionSettings = {
    disclaimed = true;
  };

  jupyterVimSettings = {
    enabled = true;
    enabledInEditors = true;
    extraKeybindings = [
      { 
        command = "jk";
        keys = "<Esc>";
        context = "insert";
        enabled = true;
      }
      { 
        command = ",";
        keys = ";";
        mapfn = "noremap";
        enabled = true;
      }
      { 
        command = ";";
        keys = ":";
        context = "visual";
        enabled = true;
      }
      { 
        command = ";";
        keys = ":";
        enabled = true;
      }
      { 
        command = "Y";
        keys = "y$";
        enabled = true;
      }
      { 
        command = "H";
        keys = "^";
        enabled = true;
      }
      { 
        command = "L";
        keys = "$";
        enabled = true;
      }
      { 
        command = "\\n";
        keys = ":nohlsearch";
        enabled = true;
      }
    ];
  };
in
{
  home.packages = with pkgs; [
    # -- Shell scripting tools --
    shellcheck  # static analysis/linter(?) for bash/sh
    shfmt       # shell script formatter

    # -- Nix tools --
    # NOTE: commented out because it's somehow bringing in nix 2.15.3 as
    # a dependency??
    #rnix-lsp           # nix language server
    nixfmt-rfc-style    # nix formatter
    deadnix             # nix dead code locator (no idea what this is)
    statix              # nix linter

    pre-commit  # we want this separately so we can apply even to non-python projects
    unstable.micromamba  # python environment management

    # -- MY tools! --
    add-jupyter-env # run inside a conda env to add jupyter lab setup
    sri-hash        # quick nix utility to grab the sri from a github repo
  ];

  # TODO: put in fancier vim plugins stuff

  # ==========================================
  # Jupyter lab configs
  # ==========================================

  home.activation = let
    jupyterVimSettingsLoc = "${config.home.homeDirectory}/.jupyter/lab/user-settings/@axlair/jupyterlab_vim/plugin.jupyterlab-settings";
    jupyterThemeSettingsLoc = "${config.home.homeDirectory}/.jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings";
    jupyterExtensionSettingsLoc = "${config.home.homeDirectory}/.jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/plugin.jupyterlab-settings";
  in {
    removeExistingJupyterLabSettings = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -rf "${jupyterVimSettingsLoc}"
      rm -rf "${jupyterThemeSettingsLoc}"
      rm -rf "${jupyterExtensionSettingsLoc}"
    '';
    copyInJupyterLabSettings = let
      jsonTheme = pkgs.writeText "tmp_theme_settings" (builtins.toJSON jupyterThemeSettings);
      jsonExtensions = pkgs.writeText "tmp_extension_settings" (builtins.toJSON jupyterExtensionSettings);
      jsonVim = pkgs.writeText "tmp_vim_settings" (builtins.toJSON jupyterVimSettings);
    in lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      cat ${jsonTheme} | ${pkgs.jq}/bin/jq --monochrome-output > "${jupyterThemeSettingsLoc}"
      cat ${jsonExtensions} | ${pkgs.jq}/bin/jq --monochrome-output > "${jupyterExtensionSettingsLoc}"
      cat ${jsonVim} | ${pkgs.jq}/bin/jq --monochrome-output > "${jupyterVimSettingsLoc}"
    '';
  };

  # ==========================================
  # Set up micromamba
  # ==========================================

  home.file.".mambarc".text = ''
   channels:
   - conda-forge
  '';

  programs.zsh.initContent = /* sh */ ''
    # >>> mamba initialize >>>
    export MAMBA_EXE='${pkgs.unstable.micromamba}/bin/micromamba';
    export MAMBA_ROOT_PREFIX="''${HOME}/micromamba";
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [ $? -eq 0 ]; then 
        eval "$__mamba_setup"
    else
        alias micromamba="$MAMBA_EXE"
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
  '';
  
  programs.bash.initExtra = /* sh */ ''
    # >>> mamba initialize >>>
    export MAMBA_EXE='${pkgs.unstable.micromamba}/bin/micromamba';
    export MAMBA_ROOT_PREFIX="''${HOME}/micromamba";
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [ $? -eq 0 ]; then 
        eval "$__mamba_setup"
    else
        alias micromamba="$MAMBA_EXE"
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<
  '';
}
