# Top level import module for all nixos systems. We load
# the system-specific module based on the passed hostname.

{ inputs, lib, hostname, timezone, pkgs, ... }:
{
  imports = [ ./${hostname} ];

  networking.hostName = hostname;

  # always have these packages!
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
  ];

  
  # internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # set timezone
  time.timeZone = timezone;
  
  # nix settings
  nix = {
    package = pkgs.nixUnstable;

    settings = {
      # detects files in store with identical contents and uses single copy
      auto-optimise-store = true; 
    };
    
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # none of my systems are probably going to be regularly experiencing high
    # CPU load, so let's just make it work better for responsiveness, and only
    # allow nix daemon to do things in times of cpu idle
    daemonCPUSchedPolicy = "idle" ;
    
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };
  nixpkgs.config.allowUnfree = true;

  # ssh stuff
  # services.openssh = {
  #   enable = true;
  #   passwordAuthentication = false;
  #   permitRootLogin = "no"
  # };
  # programs.ssh = {
  #   knownHostsFiles = lib.filesystem.listFilesRecursive ./public_ssh_keys;
  # };
}
