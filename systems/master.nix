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
    growPartition = true;
    kernelPackages = pkgs.linuxPackages_virtio;
  };

  imports = [
    ../modules/k3s-manifests.nix
    ../modules/netboot/server.nix
    ../modules/common.nix
    (import <nixpkgs/nixos/modules/profiles/qemu-guest.nix>)
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

  networking = {
    hostName = "k3s-master";
    interfaces.eth0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = networkConfig.netBoot.masterIp;
          prefixLength = networkConfig.netBoot.cidr;
        }
      ];
    };
    interfaces.eth1 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = networkConfig.appTraffic.masterIp;
          prefixLength = networkConfig.appTraffic.cidr;
        }
      ];
    };
    interfaces.eth2 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = networkConfig.k3sApi.masterIp;
          prefixLength = networkConfig.k3sApi.cidr;
        }
      ];
    };
    defaultGateway = {
      address = networkConfig.appTraffic.gateway;
      interface = "eth0";
    };
  };

  netboot = {
    interface = "eth0";
    ipRange = "${networkConfig.netBoot.dhcpRange.start},${networkConfig.netBoot.dhcpRange.end}";
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
      extraFlags = [
        "--flannel-iface=eth0"
      ];
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
    rootDevice = "/dev/disk/by-label/nixos";
  };
}
