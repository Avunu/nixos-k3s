{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    # Enhance initrd for BTRFS auto-detection
    boot.initrd = {
      availableKernelModules = [
        "btrfs"
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "btrfs" ];

      extraUtilsCommands = ''
        copy_bin_and_libs ${pkgs.btrfs-progs}/bin/btrfs
        copy_bin_and_libs ${pkgs.util-linux}/bin/blkid
      '';

      postDeviceCommands = lib.mkBefore (builtins.readFile ./post-device-commands.sh);
    };
  };
}
