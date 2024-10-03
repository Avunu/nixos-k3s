{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
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

  imports = [
    ./images.nix
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
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://attic.batonac.com/k3s"
      ];
      trusted-public-keys = [
        "k3s:A8GYNJNy2p/ZMtxVlKuy1nZ8bnZ84PVfqPO6kg6A6qY="
      ];
    };
  };

  services = {

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
      name = "iqn.2021-05.local.k3s:" + builtins.readFile "/etc/hostname";
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
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      (builtins.readFile "/etc/pubkey")
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
