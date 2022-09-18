# Installing vscode through nix can be problematic because even basic settings
# like changing your theme or the zoom level or random other things tries to
# update the user settings.json. Unfortunately, if that settings was created by
# nix, it's immutable and stuff errors and gets mad. This solution, found at  
# https://github.com/nix-community/home-manager/issues/1800, is a module that
# adds a "mutable" flag to the config, which works by copying over the settings
# file with whatever's in the store on activation. (This means it won't
# _persist_ between sessions, I believe, but it at least shouldn't error)

{ config, lib, pkgs, ... }:

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
  options.modules.home.editors.vscode = {
    enable = mkEnableOption "VS Code";
    mutable = mkEnableOption "Mutable configuration";
  };

  config = mkIf cfg.enable {
    home = {
      activation = mkIf cfg.mutable {
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
  };
}
