{
  description = "Nix flake for building NixOS images for k3s server and agent nodes using cloud-init, with common configuration module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = nixpkgs.lib;

      # Common configuration module
      commonModule =
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
            loader.grub.device = "/dev/sda";
          };

          documentation = {
            enable = false;
            doc.enable = false;
            man.enable = false;
            nixos.enable = false;
          };

          environment.systemPackages = with pkgs; [
            openiscsi
            libiscsi
            nfs-utils
            nvme-cli
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

          fileSystems."/" = {
            device = "/dev/sda1";
            fsType = "ext4";
          };

          services = {

            cloud-init = {
              enable = true;
              network.enable = true;
              config = ''
                system_info:
                  distro: nixos
                  network:
                    renderers: [ 'networkd' ]
                  default_user:
                    name: ops
                users:
                    - default
                ssh_pwauth: false
                chpasswd:
                  expire: false
                cloud_init_modules:
                  - migrator
                  - seed_random
                  - growpart
                  - resizefs
                cloud_config_modules:
                  - disk_setup
                  - mounts
                  - set-passwords
                  - ssh
                cloud_final_modules: []
              '';
            };

            k3s = {
              enable = true;
              extraFlags = [
                "--disable traefik" # Disable default ingress as we'll use Octavia
                "--disable servicelb" # Disable default load balancer
                "--disable local-storage" # Disable default storage as we'll use Longhorn
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
              name = "iqn.2024-01.org.nixos:01:${config.networking.hostName}";
            };
            
            openssh.enable = true;

            qemuGuest.enable = true;

          };

          users.users.ops = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };

          systemd.network.enable = true;

          security.sudo.wheelNeedsPassword = false;

          system = {
            autoUpgrade = {
              enable = true;
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

          zramSwap.enable = true;
        };
    in
    {
      packages.${system} = {
        serverImage = self.nixosConfigurations.server.config.system.build.image;
        agentImage = self.nixosConfigurations.agent.config.system.build.image;
      };

      nixosConfigurations = {

        agent = lib.nixosSystem {
          inherit system;
          modules = [
            commonModule
            (
              { config, pkgs, ... }:
              {
                # Agent-specific configuration
                services.k3s = {
                  serverAddr = "https://10.24.0.254:6443";
                  role = "agent";
                };

                # Auto-upgrade settings
                system.autoUpgrade = {
                  flake = "github:avunu/k3s#agent";
                  allowReboot = true;
                };
              }
            )
          ];
        };

        server = lib.nixosSystem {
          inherit system;
          modules = [
            commonModule
            (
              { config, pkgs, ... }:
              {
                # Server-specific configuration
                services.k3s = {
                  extraFlags = [
                    "--cluster-cidr 10.42.0.0/16"
                    "--service-cidr 10.43.0.0/16"
                    "--cluster-dns 10.43.0.10"
                    "--flannel-backend none" # We'll use Calico for networking
                  ];
                  role = "server";
                  disableAgent = true;
                };

                # Auto-upgrade settings
                system.autoUpgrade = {
                  flake = "github:avunu/k3s#server";
                  allowReboot = false;
                };
              }
            )
          ];
        };
      };
    };
}
