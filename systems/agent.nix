{
  config,
  lib,
  pkgs,
  ...
}:

let
  networkConfig = (import ../network-config.nix).networkConfig;
in
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
    kernelPackages = pkgs.linuxPackages_metal;
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

  networking = {
    bonds.bond0 = {
      interfaces = [
        "eth0"
        "eth1"
      ];
      driverOptions = {
        mode = "802.3ad";
        miimon = "100";
      };
    };
    interfaces.bond0 = {
      useDHCP = true;
    };
    vlans = {
      "${networkConfig.appTraffic.name}" = {
        id = networkConfig.appTraffic.vlanId;
        interface = "bond0";
      };
      "${networkConfig.k3sApi.name}" = {
        id = networkConfig.k3sApi.vlanId;
        interface = "bond0";
      };
      "${networkConfig.storage.name}" = {
        id = networkConfig.storage.vlanId;
        interface = "bond0";
      };
    };
    interfaces.${networkConfig.appTraffic.name} = {
      useDHCP = true;
    };
    interfaces.${networkConfig.k3sApi.name} = {
      useDHCP = true;
    };
    interfaces.${networkConfig.storage.name} = {
      useDHCP = true;
      mtu = networkConfig.storage.jumboFrames.mtu;
    };
  };

  # Agent-specific configuration
  services = {
    btrfs.autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
      interval = "daily";
    };

    k3s = {
      extraFlags = [
        "--flannel-iface=bond0" # Use the bonded interface for Flannel
      ];
      serverAddr = "https://${networkConfig.k3sApi.masterIp}:6443";
      role = "agent";
    };
  };

  # Auto-upgrade settings
  system.autoUpgrade = {
    flake = "github:avunu/nixos-k3s#agent";
    allowReboot = true;
  };
}
