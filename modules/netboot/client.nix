{ pkgs, lib, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      availableKernelModules = [
        "btrfs"
        "xhci_pci"
        "ahci"
        "nvme"
      ];
      kernelModules = [ "btrfs" ];

      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.btrfs-progs}/bin/btrfs
        copy_bin_and_libs ${pkgs.util-linux}/bin/blkid
        copy_bin_and_libs ${pkgs.util-linux}/bin/lsblk
      '';

      postDeviceCommands = lib.mkBefore (builtins.readFile ./post-device-commands.sh);
    };
    loader = {
      grub.enable = false;
      systemd-boot.enable = true;
    };
  };
  
  # File system configured by disko
  
  system = {
    stateVersion = "24.11";
  };

}
