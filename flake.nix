{
  description = "Nix flake for building NixOS images for k3s server and agent nodes using cloud-init, with common configuration module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    lib = nixpkgs.lib;

    # Common configuration module
    commonModule = { config, pkgs, lib, ... }: {

      boot = {
        kernel.sysctl = {
          "vm.nr_hugepages" = 1024;
        };
        kernelModules = [
          "vfio_pci"
          "uio_pci_generic"
          "nvme-tcp"
        ];
        kernelPackages = pkgs.linuxPackages_latest;
        loader.grub.device = "/dev/sda";
      };

      documentation = {
        enable = mkDefault false;
        doc.enable = mkDefault false;
        man.enable = mkDefault false;
        nixos.enable = mkDefault false;
      };

      imports = [
        "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
      ];

      networking = {
        defaultGateway = { address = "10.24.0.1"; interface = "eth0"; };
        dhcpcd.enable = false;
        interfaces.eth0.useDHCP = false;
      };

      nix = {
        gc = {
          automatic = mkDefault true;
          dates = mkDefault "weekly";
          options = mkDefault "--delete-older-than 7d";
        };
        settings.experimental-features = mkDefault [ "nix-command" "flakes" ];
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
          tokenFile = "/etc/k3s/tokenFile";
          environmentFile = "/etc/k3s/envs";
        };
        fstrim = {
          enable = mkDefault true;
          interval = mkDefault "daily";
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

      system.autoUpgrade = {
        enable = true;
      };

      zramSwap.enable = mkDefault true;

    };
  in {
    packages.${system} = {
      serverImage = pkgs.nixosConfigurations.server.config.system.build.diskImage;
      agentImage = pkgs.nixosConfigurations.agent.config.system.build.diskImage;
    };

    nixosConfigurations = {
      server = pkgs.nixosSystem {
        system = "x86_64-linux";
        modules = [
          commonModule
          { config, pkgs, lib, ... }: {
            # Server-specific configuration
            services.k3s = {
              extraFlags = [
                "--no-deploy traefik"
                "--cluster-cidr 10.24.0.0/16"
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
        ];
      };

      agent = pkgs.nixosSystem {
        system = "x86_64-linux";
        modules = [
          commonModule
          { config, pkgs, lib, ... }: {
            # Agent-specific configuration
            services.k3s = {
              serverAddr = "https://10.24.0.254:6443"; # Replace with actual server address
              role = "agent";
            };

            # Auto-upgrade settings
            system.autoUpgrade = {
              flake = "github:avunu/k3s#server";
              allowReboot = true;
            };
          }
        ];
      };
    };
  };
}
