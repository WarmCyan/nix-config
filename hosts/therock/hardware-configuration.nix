{ config, lib, pkgs, modulesPath, ... }:
{
  imports = 
  [ (modulesPath + "/installer/scan/not-detected.nix")
  ];
  
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "ohci_pci" "ehci_pci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # zfs support
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  # boot.zfs.extraPools = [ "backup_depository" ];
  networking.hostId = "b296d82c";
  # host id generated with `head -c4 /dev/uranodm | od -A none -t x4`,
  # see https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html#installation

  # 500G ssd
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
    
  # 500G hard disk
  fileSystems."/storage" = { 
    device = "/dev/disk/by-uuid/15a5eafa-4cb3-42c5-ac26-2ab4d1fb5e93";
    fsType = "ext4";
  };

  # # USB dock for cold storage hot swapped 8tb disks
  # fileSystems."/backup_depository" = {
  #   device = "/dev/disk/by-id/usb-USB_3.0_HDD_Docking_Station_201710310028-0:0";
  #   fsType = "ext4";
  # };

  # zfs mirror'd two 8tb disks
  fileSystems."/depository" = {
    device = "depository/root";
    fsType = "zfs";
  };
  
  # zfs backup pool on the HDD docking station
  # fileSystems."/backup_depository" = {
  #   device = "backup_depository/root";
  #   fsType = "zfs";
  #   # the zfsutil option is needed when mounting zfs datasets without "legacy" mountpoints
  #   options = [ "zfsutil" ];
  # };


  networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  #nixpkgs.hostPlatform.system = "x86_64-linux";
}
