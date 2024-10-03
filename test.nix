{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.test.nix
  ];

  networking.hostName = "k3s-master";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };

  services.k3s = {
    enable = true;
    role = "server";
  };
}
