{
  config,
  lib,
  pkgs,
  ...
}:
let
  kernel = pkgs.linuxPackages_latest.overrideAttrs (oldAttrs: {
    # optimizations
    extraConfig = ''
      CC = "${pkgs.llvmPackages_19.clang}/bin/clang";
      CXX = "${pkgs.llvmPackages_19.clang}/bin/clang++";
      CFLAGS="$CFLAGS -march=x86-64-v4 -mtune=x86-64-v4 -O3 -flto"
      LDFLAGS="$LDFLAGS -flto"
    '';
  });
in
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
    kernelPackages = kernel;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        configurationLimit = 10;
        enable = true;
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

  imports = [ "${pkgs.path}/nixos/modules/profiles/qemu-guest.nix" ];

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
        "--cluster-dns=10.43.0.10"
        "--container-runtime-endpoint=unix:///run/crio/crio.sock"
        "--disable-cloud-controller"
        "--disable=local-storage"
        "--disable=servicelb"
        "--disable=traefik"
        "--flannel-backend=vxlan"
        "--kubelet-arg='cloud-provider=external'"
        "--kubelet-arg='provider-id=openstack://$master_id'"
        "--service-cidr=10.43.0.0/16"
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
    extraGroups = [
      "podman"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      builtins.getEnv
      "SSH_PUBKEY"
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
    build.image = pkgs.nixos.lib.makeImage {
      inherit config lib pkgs;
      format = "qcow2-compressed";
      installBootLoader = true;
    };
    stateVersion = "24.05";
  };

  virtualisation = {
    cri-o = {
      enable = true;
      storageDriver = "btrfs";
      runtime = "crun";
    };
  };

  zramSwap.enable = true;
}
