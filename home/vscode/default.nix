{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.home.editors.vscode;
  vscodePname = config.programs.vscode.package.pname;

  configDir = {
    "vscode" = "Code";
    "vscode-insiders" = "Code - Insiders";
    "vscodium" = "VSCodium";
  }.${vscodePname};

  sysDir = if pkgs.stdenv.hostPlatform.isDarwin then
    "${config.home.homeDirectory}/Library/Application Support"
  else
    "${config.xdg.configHome}";

  userFilePath = "${sysDir}/${configDir}/User/settings.json";
in {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true; # allows vscode to install/update extensions without going thru nix
    #mutable = true;

    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      ms-vscode-remote.remote-ssh
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-renderers
      ms-vsliveshare.vsliveshare
      #sainnhe.everforest
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

  home = {
    activation = {
      removeExistingVSCodeSettings = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
        rm -rf "${userFilePath}"
      '';
      
      overwriteVSCodeSymlink = let
        userSettings = config.programs.vscode.userSettings;
        jsonSettings = pkgs.writeText "tmp_vscode_settings" (builtins.toJSON userSettings);
      in lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        rm -rf "${userFilePath}"
        cat ${jsonSettings} | ${pkgs.jq}/bin/jq --monochrome-output > "${userFilePath}"
      '';
    };
  };
}
