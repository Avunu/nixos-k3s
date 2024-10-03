{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./modules/k3s-services.nix
    ./modules/netboot/server.nix
    ./modules/common.nix
  ];

  netboot = {
    interface = "enp0s3";
    ipRange = "192.168.1.100,192.168.1.200";
    domainName = "k3s.avunu.io";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };

  networking.hostName = "k3s-master";

  # Server-specific configuration
  services.k3s = {
    role = "server";
    disableAgent = true;
  };

  # Auto-upgrade settings
  system.autoUpgrade = {
    flake = "github:avunu/nixos-k3s#master";
    allowReboot = false;
  };
}
