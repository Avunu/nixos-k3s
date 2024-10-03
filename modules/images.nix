{
  config,
  lib,
  pkgs,
  ...
}:

{
  system = {
    build = {
      image = lib.mkForce (
        pkgs.callPackage "${pkgs.path}/nixos/lib/make-disk-image.nix" {
          inherit config lib pkgs;
          diskSize = 8192;
          format = "qcow2-compressed";
          installBootLoader = true;
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
