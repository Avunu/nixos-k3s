{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernel.sysctl = {
      "vm.nr_hugepages" = 1024;
    };
    kernelModules = [
      "nbd"
      "nvme-rdma"
      "nvme-tcp"
      "uio_pci_generic"
      "vfio_pci"
      "iscsi_tcp"
    ];
    kernelPackages = pkgs.linuxPackages_agent;
  };

  # root file system
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd"
    ];
  };

  imports = [
    ./modules/netboot/client.nix
    ./modules/common.nix
  ];

  # Agent-specific configuration
  services = {
    btrfs.autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
      interval = "daily";
    };

    k3s = {
      serverAddr = "https://10.24.0.254:6443";
      role = "agent";
    };
  };

  # Auto-upgrade settings
  system.autoUpgrade = {
    flake = "github:avunu/nixos-k3s#agent";
    allowReboot = true;
  };
}
