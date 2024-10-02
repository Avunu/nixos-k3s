{ config, pkgs, ... }:
{
  # Agent-specific configuration
  services.k3s = {
    serverAddr = "https://10.24.0.254:6443";
    role = "agent";
  };

  # Auto-upgrade settings
  system.autoUpgrade = {
    flake = "github:avunu/nixos-k3s#agent";
    allowReboot = true;
  };
}
