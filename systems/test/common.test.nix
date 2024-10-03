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
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        configurationLimit = 10;
        enable = true;
      };
    };
  };

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
}
