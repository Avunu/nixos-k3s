{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.initrd = {
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

  imports = [
    ./modules/k3s-services.nix
    ./modules/netboot/server.nix
    ./modules/common.nix
  ];

  netboot = {
    interface = "enp0s3";
    ipRange = "192.168.1.100,192.168.1.200";
    domainName = "k3s.local";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };

  networking.hostName = "k3s-master";

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

  };

  # Auto-upgrade settings
  system.autoUpgrade = {
    flake = "github:avunu/nixos-k3s#master";
    allowReboot = false;
  };

  virtualisation.qemu.guestAgent.enable = true;
}
