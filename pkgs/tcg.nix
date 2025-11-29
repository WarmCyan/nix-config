{ pkgs, builders }:
let
  tmux_config_file = pkgs.writeTextFile {
    name="tcg-tmux-file.conf";
    text = builtins.readFile ./cg-tmux.conf;
  };
in
builders.writeTemplatedShellApplication {
  name = "tcg";
  version = "0.1.0";
  description = "TMUX code grep - tool to search micromamba env site package code.";
  usage = "tcg [-h|--help] [--version] [CODE_FOLDER_PATH]";
  runtimeInputs = [
    pkgs.cg
    pkgs.tmux
  ];
  exitOnError = false;
  text = /* bash */ ''
      # shellcheck disable=SC2145
      tmux -L tcg -f ${tmux_config_file} new-session cg --tmux "$@"
  '';
}
