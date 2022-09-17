{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true; # allows vscode to install/update extensions without going thru nix

    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ms-vscode-remote.remote-ssh
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-renderers
      ms-vsliveshare.vsliveshare
      sainnhe.everforest
    ];

    userSettings = {
      "vim.cursorStylePerMode.normal" = "block";
      "vim.cursorStylePerMode.insert" = "line";
      "vim.insertModeKeyBindingsNonRecursive" = [
        {
          "before" = ["j" "k"];
          "after" = ["<SPACE>" "<BS>" "<ESC>"];
        }
      ];
      "vim.normalModeKeyBindingsNonRecursive" = [
        { "before" = [","]; "after" = [";"]; }
        { "before" = [";"]; "after" = [":"]; }
        { "before" = ["Y"]; "after" = ["y" "$"]; }
        { "before" = ["H"]; "after" = ["^"]; }
        { "before" = ["L"]; "after" = ["$"]; }
        { "before" = ["<C-h>"]; "after" = ["<C-w>" "h"]; }
        { "before" = ["<C-j>"]; "after" = ["<C-w>" "j"]; }
        { "before" = ["<C-k>"]; "after" = ["<C-w>" "k"]; }
        { "before" = ["<C-l>"]; "after" = ["<C-w>" "l"]; }
      ];
      "vim.visualModeKeyBindingsNonRecursive" = [
        { "before" = [";"]; "after" = [":"]; }
      ];
      
      "workbench.colorTheme" = "Everforest Dark";
      "everforest.darkContrast" = "hard";
      "everforest.darkWorkbench" = "flat";
      
      "terminal.integrated.inheritEnv" = false;
      
      "editor.multiCursorModifier" = "ctrlCmd";
      "editor.definitionLinkOpensInPeek" = true;
      "editor.stickyScroll.enabled" = true;

      "diffEditor.codeLens" = true;

      "window.titleBarStyle" = "custom";
    };
  };
}
