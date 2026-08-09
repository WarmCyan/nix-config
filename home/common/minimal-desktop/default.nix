# see ../../../hosts/common/minimal-desktop/default.nix for nixos-side
{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.desktop.minimalX;
in
{
  options.desktop.minimalX = {
    enable = mkEnableOption "Minimal xorg DE-less, greeter-less setup";
  };

  config = mkIf cfg.enable {
    programs.bash.profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ] && [[ "$(tty)" == *"/dev/tty"* ]]; then
        exec startx
      fi
    '';
    programs.zsh.profileExtra = ''
      if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ] && [[ "$(tty)" == *"/dev/tty"* ]]; then
        exec startx
      fi
    '';
    
    home.file.".xinitrc".text = ''
      if test -z "$DBUS_SESSION_BUS_ADDRESS"; then
        eval $(dbus-launch --exit-with-session --sh-syntax)
      fi
      systemctl --user import-environment DISPLAY XAUTHORITY

      if command -v dbus-update-activation-environment >/dev/null 2>&1; then
              dbus-update-activation-environment DISPLAY XAUTHORITY
      fi

      ${pkgs.kbd-capslock}/bin/kbd-capslock

      exec $HOME/.xsession
    '';
  };
}
