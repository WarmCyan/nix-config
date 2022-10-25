{ config, lib, pkgs, modulesPath, ... }:
{
  imports = 
  [ (modulesPath + "/installer/scan/not-detected.nix")
  ];
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/bb8a1b85-f8d9-46e0-bf26-6d5b2f966465";
      fsType = "ext4";
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/B519-BA0F";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/61304672-bad1-429b-9992-f7156d1fb9c8"; }
    ];

    networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  #nixpkgs.hostPlatform.system = "x86_64-linux";
}
