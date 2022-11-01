# Top level import module for all nixos systems. We load
# the system-specific module based on the passed hostname.

{ self, inputs, lib, hostname, configName, configLocation, timezone, pkgs, ... }:
let
  inherit (builtins) toString;
in
{
  imports = [ ./${configName} ];

  networking.hostName = hostname; # TODO: no move this to the machine

  # always have these packages! These are for basic debugging purposes
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    iproute2
    gnufdisk
    htop
    ncdu

    iris
  ];

  environment.etc."iris/configname".text = configName;
  environment.etc."iris/configlocation".text = configLocation;
  environment.etc."iris/configRev".text = self.rev or "dirty";
  environment.etc."iris/configShortRev".text = self.shortRev or "dirty";
  environment.etc."iris/configRevCount".text = if (self ? revCount) then toString self.revCount else "dirty";
  environment.etc."iris/configLastModified".text = if (self ? lastModified) then toString self.lastModified else "dirty";
  

  
  # internationalisation properties.
  i18n.defaultLocale = lib.mkDefault "en_US.utf8";

  # set timezone # TODO: no move this to the machine
  time.timeZone = timezone;
  
  # nix settings
  nix = {
    package = pkgs.nixUnstable;

    settings = {
      # detects files in store with identical contents and uses single copy
      auto-optimise-store = lib.mkDefault true; 
    };
    
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # none of my systems are probably going to be regularly experiencing high
    # CPU load, so let's just make it work better for responsiveness, and only
    # allow nix daemon to do things in times of cpu idle
    # daemonCPUSchedPolicy = lib.mkDefault "idle";
    
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
    };
  };
  nixpkgs.config.allowUnfree = true;
}
