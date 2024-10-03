{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./modules/netboot/client.nix
    ./modules/common.nix
  ];

  # root file system
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd"
    ];
  };

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
