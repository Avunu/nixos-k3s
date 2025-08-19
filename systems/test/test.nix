{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../modules/disko-test.nix
    ./common.test.nix
  ];

  networking.hostName = "k3s-master";

  # File system configured by disko

  services.k3s = {
    enable = true;
    role = "server";
  };
}
