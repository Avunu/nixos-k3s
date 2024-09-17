{
  description = "Nix flake for building NixOS images for k3s server and agent nodes using cloud-init, with common configuration module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    longhorn = {
      url = "github:longhorn/longhorn";
      flake = false;
      rev = "v1.7.1";
    };

    prometheus = {
      url = "github:prometheus-operator/prometheus-operator";
      flake = false;
      rev = "v0.76.2";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      longhorn,
      prometheus,
      ...
    }:
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
            coreutils
            bashInteractive
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
                cloud_final_modules:
                  - scripts-user
                runcmd:
                  - [ sed, -i, "s/\$\{HOSTNAME\}/$(hostname)/g", "/etc/iscsi/initiatorname.iscsi" ]
              '';
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
              name = "iqn.2024-01.org.nixos:01:$\{HOSTNAME}";
            };

            openssh = {
              enable = true;
              permitRootLogin = "no";
              passwordAuthentication = false;
            };

            qemuGuest.enable = true;

          };

          users.users.ops = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };

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
                  flake = "github:avunu/nixos-k3s#agent";
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
                  # extraFlags = [
                  #   "--cluster-cidr 10.42.0.0/16"
                  #   "--service-cidr 10.43.0.0/16"
                  #   "--cluster-dns 10.43.0.10"
                  # ];
                  manifests = {
                    longhorn = {
                      source = "${longhorn}/deploy/longhorn.yaml";
                    };
                    # Deploy Prometheus using HelmChart resource
                    prometheus = {
                      source = ''
                        apiVersion: helm.cattle.io/v1
                        kind: HelmChart
                        metadata:
                          name: prometheus
                          namespace: kube-system
                        spec:
                          chart: prometheus-community/prometheus
                          version: "20.0.1"
                          repo: https://prometheus-community.github.io/helm-charts
                          targetNamespace: monitoring
                          valuesContent: |-
                            alertmanager:
                              enabled: true
                            server:
                              persistentVolume:
                                enabled: true
                                size: 8Gi
                      '';
                    };

                    # Deploy kube-state-metrics using HelmChart resource
                    kubeStateMetrics = {
                      source = ''
                        apiVersion: helm.cattle.io/v1
                        kind: HelmChart
                        metadata:
                          name: kube-state-metrics
                          namespace: kube-system
                        spec:
                          chart: prometheus-community/kube-state-metrics
                          version: "5.11.5"
                          repo: https://prometheus-community.github.io/helm-charts
                          targetNamespace: monitoring
                      '';
                    };

                    # Deploy cert-manager using HelmChart resource
                    certManager = {
                      source = ''
                        apiVersion: helm.cattle.io/v1
                        kind: HelmChart
                        metadata:
                          name: cert-manager
                          namespace: kube-system
                        spec:
                          chart: jetstack/cert-manager
                          version: "v1.12.0"
                          repo: https://charts.jetstack.io
                          targetNamespace: cert-manager
                          set:
                            installCRDs: "true"
                      '';
                    };

                  };
                  role = "server";
                  disableAgent = true;
                };

                # Auto-upgrade settings
                system.autoUpgrade = {
                  flake = "github:avunu/nixos-k3s#server";
                  allowReboot = false;
                };
              }
            )
          ];
        };
      };
    };
}
