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
          format = "qcow2-compressed";
          diskSize = 8192;
          installBootLoader = true;
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
