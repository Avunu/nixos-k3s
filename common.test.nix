{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  environment.systemPackages = with pkgs; [
    bashInteractive
    coreutils
    util-linux
  ];

  networking = {
    dhcpcd.enable = false;
    useNetworkd = true;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  system = {
    stateVersion = "24.05";
  };
}
