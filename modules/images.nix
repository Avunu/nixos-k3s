{
  config,
  lib,
  pkgs,
  ...
}:

{
  system = {
    build = {
      # For systems with disko configuration, we'll rely on disko's 
      # built-in support. For now, let's keep the traditional approach
      # but update it to work with btrfs
      image = lib.mkForce (
        pkgs.callPackage "${pkgs.path}/nixos/lib/make-disk-image.nix" {
          inherit config lib pkgs;
          diskSize = 8192;
          format = "qcow2-compressed";
          installBootLoader = true;
          touchEFIVars = true;
          # Update to use btrfs to match our disko config
          fsType = "btrfs";
          label = "rootfs";
          partitionTableType = "efi";
        }
      );

      isoImage = lib.mkForce (
        (lib.nixosSystem {
          inherit (pkgs.stdenv.hostPlatform) system;
          modules = [
            "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            config
          ];
        }).config.system.build.isoImage
      );
    };
  };
}
