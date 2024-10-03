{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    growPartition = true;
    initrd = {
      availableKernelModules = [
        "virtio_net"
        "virtio_pci"
        "virtio_mmio"
        "virtio_blk"
        "virtio_scsi"
      ];
      kernelModules = [
        "virtio_balloon"
        "virtio_console"
        "virtio_rng"
      ];
    };
    kernelPackages = pkgs.linuxPackages_virtio;
  };

  imports = [
    ../modules/k3s-manifests.nix
    ../modules/netboot/server.nix
    ../modules/common.nix
    (import <nixpkgs/nixos/modules/virtualisation/qemu-vm.nix>)
  ];

  environment.systemPackages = [ pkgs.efibootmgr ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  networking.hostName = "k3s-master";

  netboot = {
    interface = "enp0s3";
    ipRange = "192.168.1.100,192.168.1.200";
    domainName = "k3s.local";
  };

  # Server-specific configuration
  services = {

    cloud-init = {
      enable = true;
      network.enable = true;
      config = builtins.readFile ./cloud-init.yaml;
    };

    k3s = {
      role = "server";
      disableAgent = true;
    };

    qemuGuest.enable = true;

  };

  # Auto-upgrade settings
  system.autoUpgrade = {
    flake = "github:avunu/nixos-k3s#master";
    allowReboot = false;
  };

  virtualisation = {
    useBootLoader = true;
    useEFIBoot = true;
    rootDevice = "/dev/vda";
  };
}