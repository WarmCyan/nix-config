{ pkgs, lib, ... }:
{
  # debug with `fc-list | grep 'fontname'`
  # https://nixos.wiki/wiki/Fonts
  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    powerline-fonts
    (nerdfonts.override { fonts = [ "Iosevka" "Inconsolata" ]; })
    # nerdfonts
  ];
}
