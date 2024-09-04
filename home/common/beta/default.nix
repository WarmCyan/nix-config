{ pkgs, ... }:
{
  home.packages = with pkgs; [
    testing # my first nix shell package thingy!
    testing2

    export-dots

    engilog
  ];

  # home.file.".jupyter/lab/user-settings/@axlair/jupyterlab_vim/plugin.jupyterlab-settings".text = /* json */ ''
  # {
  #   // Notebook Vim
  #   // @axlair/jupyterlab_vim:plugin
  #   // Notebook Vim Settings
  #   // *****************************
  #
  #   "enabled": true,
  #   "enabledInEditors": true,
  #   "extraKeybindings": [
  #     {
  #       "command": "jk",
  #       "keys": "<Esc>",
  #       "context": "insert",
  #       "enabled": true
  #     },
  #     {
  #       "command": ",",
  #       "keys": ";",
  #       "mapfn": "noremap",
  #       "enabled": true
  #     },
  #     {
  #       "command": ";",
  #       "keys": ":",
  #       "context": "visual",
  #       "enabled": true
  #     },
  #     {
  #       "command": ";",
  #       "keys": ":",
  #       "enabled": true
  #     },
  #     {
  #       "command": "Y",
  #       "keys": "y$",
  #       "enabled": true
  #     },
  #     {
  #       "command": "H",
  #       "keys": "^",
  #       "enabled": true
  #     },
  #     {
  #       "command": "L",
  #       "keys": "$",
  #       "enabled": true
  #     },
  #     {
  #       "command": "\\n",
  #       "keys": ":nohlsearch",
  #       "enabled": true
  #     }
  #   ]
  # }
  # '';
  #
  # (move to dev when tested)
  # home.file.".jupyter/lab/user-settings/jupyterlab-vimrc/vimrc.jupyterlab-settings".text = /* json */ ''
  #   {
  #     "imap": [
  #       ["jk", "<Space><Bs><Esc>"]
  #     ],
  #     "nnoremap": [
  #       [",", ";"]
  #     ],
  #     "nmap": [
  #       [";", ":"],
  #       ["Y", "y$"],
  #       ["H", "^"],
  #       ["L", "$"],
  #       [":n", ":nohlsearch"]
  #     ],
  #     "vmap": [
  #       [";", ":"]
  #     ]
  #   }
  # '';

  # home.file.".jupyter/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings".text = /* json */ ''
  # {
  #   // Theme
  #   // @jupyterlab/apputils-extension:themes
  #   // Theme manager settings.
  #   // *************************************
  #
  #   // Theme CSS Overrides
  #   // Override theme CSS variables by setting key-value pairs here
  #   "overrides": {
  #     "code-font-family": null,
  #     "code-font-size": null,
  #     "content-font-family": null,
  #     "content-font-size1": null,
  #     "ui-font-family": null,
  #     "ui-font-size1": null
  #   },
  #
  #   // Selected Theme
  #   // Application-level visual styling theme
  #   "theme": "JupyterLab Dark",
  #
  #   // Scrollbar Theming
  #   // Enable/disable styling of the application scrollbars
  #   "theme-scrollbars": true
  # }
  # '';
  #
  # home.file.".jupyter/lab/user-settings/@jupyterlab/extensionmanager-extension/plugin.jupyterlab-settings".text = /* json */ ''
  # {
  #   // Extension Manager
  #   // @jupyterlab/extensionmanager-extension:plugin
  #   // Extension manager settings.
  #   // *********************************************
  #
  #   // Disclaimed Status
  #   // Whether the user understand that extensions managed through this interface run arbitrary code that may be dangerous
  #   "disclaimed": true
  # }
  # '';
}
