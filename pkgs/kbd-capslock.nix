{ pkgs, builders }:
builders.writeTemplatedShellApplication {
  name = "kbd-capslock";
  description = "This sets the caps lock key to be a hyper key instead.";
  usage = "kbd-capslock";
  runtimeInputs = [ pkgs.xorg.xmodmap ];
  text = /* bash */ ''
  xmodmap -e "clear lock"
  xmodmap -e "clear mod4"
  xmodmap -e "clear mod5"
  xmodmap -e "keycode 66 = Hyper_L"
  xmodmap -e "!add lock = Hyper_L" # I assume this doesn't work
  xmodmap -e "add mod4 = Super_L Super_R"
  xmodmap -e "add mod5 = Hyper_L"
  '';
}

