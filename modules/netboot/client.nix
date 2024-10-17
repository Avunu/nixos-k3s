{ pkgs, lib, ... }:
{
  boot = {
    initrd = {
      availableKernelModules = [
        "btrfs"
        "xhci_pci"
        "ahci"
        "nvme"
      ];
      kernelModules = [ "btrfs" ];
      kernelPackages = pkgs.linuxPackages_testing;

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
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "btrfs";
  };
  system = {
    stateVersion = "24.11";
  };

}
