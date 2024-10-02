{ config, pkgs, ... }:
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
      efi.canTouchEfiVariables = mkDefault true;
      systemd-boot = {
        configurationLimit = mkDefault 10;
        enable = mkDefault true;
      };
    };
  };

  documentation = {
    enable = false;
    doc.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  environment.systemPackages = with pkgs; [
    bashInteractive
    coreutils
    libiscsi
    libiscsi
    nfs-utils
    nvme-cli
    openiscsi
    util-linux
  ];

  imports = [
    "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ];

  networking = {
    dhcpcd.enable = false;
    interfaces.eth0.useDHCP = false;
    useNetworkd = true;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  services = {

    cloud-init = {
      enable = true;
      network.enable = true;
      config = builtins.readFile ./cloud-init.yaml;
    };

    k3s = {
      enable = true;
      extraFlags = [
        "--cluster-cidr=10.42.0.0/16"
        "--service-cidr=10.43.0.0/16"
        "--cluster-dns=10.43.0.10"
        "--flannel-backend=vxlan"
        "--disable=traefik"
        "--disable=servicelb"
        "--disable=local-storage"
      ];
      tokenFile = "/etc/k3s/tokenFile";
      environmentFile = "/etc/k3s/envs";
    };

    fstrim = {
      enable = true;
      interval = "daily";
    };

    openiscsi = {
      enable = true;
      name = "iqn.2021-05.io.avunu.k3s:" + builtins.readFile "/etc/hostname";
    };

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    qemuGuest.enable = true;

  };

  users.users.ops = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPvVYtcFHwuW/QW5Sqyuno7KrsVjvC/2C3Ohx3nxDQA" # Replace with your actual public key
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  system = {
    autoUpgrade = {
      enable = true;
      flags = [
        "--impure"
      ];
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
      randomizedDelaySec = "45min";
    };
    build.image = import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
      inherit config lib pkgs;
      format = "qcow2-compressed";
      installBootLoader = true;
    };
    stateVersion = "24.05";
  };

  virtualisation.podman = {
    defaultNetwork.settings.dns_enabled = false;
    dockerCompat = true;
    dockerSocket.enable = true;
    enable = true;
  };

  zramSwap.enable = true;
}
