{ config, pkgs, ... }:
{
  # root file system
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  # Agent-specific configuration
  services = {
    btrfs.autoScrub = {
      enable = mkDefault true;
      fileSystems = mkDefault [ "/" ];
      interval = mkDefault "daily";
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
