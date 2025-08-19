{
  config,
  lib,
  pkgs,
  ...
}:

let
  networkConfig = (import ../network-config.nix).networkConfig;
in
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
    firewall.enable = true;
    nameservers = networkConfig.globalSettings.dnsServers;
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

    # BTRFS maintenance - scrub daily to detect errors
    btrfs.autoScrub = {
      enable = true;
      fileSystems = [ "/" ];
      interval = "daily";
    };

    k3s = {
      enable = true;
      extraFlags = [
        "--cluster-cidr=${networkConfig.k3sApi.subnet}/${toString networkConfig.k3sApi.cidr}"
        "--service-cidr=${networkConfig.appTraffic.subnet}/${toString networkConfig.appTraffic.cidr}"
        "--container-runtime-endpoint=unix:///run/crio/crio.sock"
        "--disable-cloud-controller"
        "--disable=local-storage"
        "--disable=servicelb"
        "--disable=traefik"
        "--flannel-backend=vxlan"
        "--kubelet-arg='cloud-provider=external'"
        "--kubelet-arg='provider-id=openstack://$master_id'"
      ];
      tokenFile = "/etc/k3s/tokenFile";
      # environmentFile = "/etc/k3s/envs";
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

    timesyncd.servers = networkConfig.globalSettings.ntpServers;

    qemuGuest.enable = true;

  };

  # longhorn looks for nsenter in specific paths, /usr/local/bin is one of
  # them so symlink the entire system/bin directory there.
  # https://github.com/longhorn/longhorn/issues/2166#issuecomment-1864656450
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
  ];

  users.users.ops = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "nixbld"
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
    stateVersion = "24.11";
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
