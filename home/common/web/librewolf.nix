{ lib, pkgs, ... }:
{
  programs.librewolf = {
    # https://nixos.wiki/wiki/Librewolf
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisplayBookmarksToolbar = "never";
      Preferences = {
        "privacy.resistFingerprinting.letterboxing" = true;
        "browser.safebrowsing.downloads.enabled" = true;
        "browser.compactmode.show" = true;
        "cookiebanners.service.mode" = 2;
        "privacy.donottrackheader.enabled" = true;

        "dom.security.https_only_mode" = false;  # don't warn for every http site (for self-hosted stuff)
        
        # TODO: I think there's a setting to enable canvases
      };
      ExtensionSettings = {
        # go to about:support to find extension IDs
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          installation_mode = "force_installed";
        };
        "search@kagi.com" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/kagi-search-for-firefox/latest.xpi";
          installation_mode = "force_installed";
        };
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
