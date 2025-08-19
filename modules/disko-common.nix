# Common disko configuration for k3s systems
# Simplified from the provided example to focus on k3s needs
{ lib ? (import <nixpkgs> {}).lib }: {
  # This function creates a disko configuration for a single disk
  # with a simplified btrfs subvolume layout suitable for k3s
  mkDiskConfig = diskDevice: {
    disko.devices = {
      disk = {
        main = {
          device = diskDevice;
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                label = "EFI";
                name = "ESP";
                size = "1024M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              swap = {
                label = "swap";
                size = "4G";
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
              root = {
                label = "rootfs";
                name = "btrfs";
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    # Root subvolume
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Home directory
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Nix store - separate for easy snapshots and management
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Log directory - separate for easier log management
                    "/var/log" = {
                      mountpoint = "/var/log";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Var lib - where k3s stores its data
                    "/var/lib" = {
                      mountpoint = "/var/lib";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}