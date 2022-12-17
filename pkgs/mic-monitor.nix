{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "mic-monitor";
  version = "0.1.0";
  description = "Turn mic loopback monitoring on/off through pactl";
  usage = "mic-monitor [on|off]";
  parameters = {};
  runtimeInputs = [ pkgs.pulseaudio ];
  text = /* bash */ ''

  if [[ $# -lt 1 ]]; then
    echo "Please specify 'on' or 'off'"
    exit 1
  fi

  case "$1" in
    on|ON|On|oN)
      pactl load-module module-loopback
      ;;
    off|OFF|Off|oFf|ofF|oFF)
      pactl unload-module module-loopback
      ;;
    *)
      echo "Please specify 'on' or 'off'"
      ;;
  esac
  '';
}
