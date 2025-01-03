{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            ccacheClangStdenv = final.callPackage ./pkgs/stdenv.nix {};
            inherit (self.packages.${system}) linux_metal linux_virtio;
          })
        ];
      };

      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        agent = lib.nixosSystem {
          inherit system pkgs;
          modules = [ ./systems/agent.nix ];
        };

        master = lib.nixosSystem {
          inherit system pkgs;
          modules = [ ./systems/master.nix ];
        };

        test = lib.nixosSystem {
          inherit system pkgs;
          modules = [ ./systems/test/test.nix ];
        };
      };

      packages.${system} = {
        linux_metal = pkgs.callPackage ./pkgs/kernel-metal.nix {};
        linux_virtio = pkgs.callPackage ./pkgs/kernel-virtio.nix {};

        agentImage = self.nixosConfigurations.agent.config.system.build.image;
        masterImage = self.nixosConfigurations.master.config.system.build.image;
        testImage = self.nixosConfigurations.test.config.system.build.image;

        agentInstallISO = self.nixosConfigurations.agent.config.system.build.isoImage;
        masterInstallISO = self.nixosConfigurations.master.config.system.build.isoImage;
        testInstallISO = self.nixosConfigurations.test.config.system.build.isoImage;
      };
    };
}
