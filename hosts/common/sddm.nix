# https://github.com/PandeCode/dotnix/blob/main/modules/wm/sddm.nix
# https://www.reddit.com/r/NixOS/comments/1kf5nr7/how_do_i_configure_sddm_theme/
# https://www.reddit.com/r/NixOS/comments/1d2g9hf/is_qt6qt5compat_broken_in_nixpkgs/
# https://github.com/a-usr/dotfiles/blob/master/hosts/silenos/configuration.nix



# https://github.com/NixOS/nixpkgs/issues/343702

# Note that the typical /usr/share is actually /run/current-system/sw/share/sddm ...


# test wwith 
# sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/chili

{ pkgs, ... }:
let
  where-is-my-sddm-theme-config = (pkgs.where-is-my-sddm-theme.override {
    themeConfig.General = {
      background = toString ./background.png;
      backgroundMode = "fill";
      # backgroundMode = "pad";
      blurRadius = 45;
      passwordCursorColor = "#000000";
      cursorBlinkAnimation = false;
      showUsersByDefault = true;
      };
  });
in
{
  services.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
    package = pkgs.kdePackages.sddm;
    # package = pkgs.libsForQt5.sddm;
    extraPackages = [
      where-is-my-sddm-theme-config
      # sddm-chili-theme
      pkgs.kdePackages.qt5compat
      # libsForQt5.qt5.qtquickcontrols
      # libsForQt5.qt5.qtgraphicaleffects
    ];
    # theme = "chili";
    theme = "where_is_my_sddm_theme";
  };
  environment.systemPackages = [
    where-is-my-sddm-theme-config
    # sddm-chili-theme
    pkgs.kdePackages.qt5compat
    # libsForQt5.qt5.qtquickcontrols
    # libsForQt5.qt5.qtgraphicaleffects
  ];
}
