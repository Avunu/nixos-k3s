{ config, lib, pkgs, ... }:

{
  config = {
    # Enable systemd-boot
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Configure network boot
    boot.loader.systemd-boot.netbootxyz.enable = true;

    # Enhance initrd for BTRFS auto-detection
    boot.initrd = {
      availableKernelModules = [ "btrfs" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "btrfs" ];

      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.btrfs-progs}/bin/btrfs
        copy_bin_and_libs ${pkgs.util-linux}/bin/blkid
      '';

      postDeviceCommands = lib.mkBefore (builtins.readFile ./post-device-commands.sh);
    };

    # Ensure root filesystem is labeled correctly
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos-root";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };
  };
}
