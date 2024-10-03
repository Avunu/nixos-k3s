{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        agent = lib.nixosSystem {
          inherit system;
          modules = [ ./agent.nix ];
        };

        master = lib.nixosSystem {
          inherit system;
          modules = [ ./master.nix ];
        };

        test = lib.nixosSystem {
          inherit system;
          modules = [ ./modules/test/test.nix ];
        };
      };

      packages.${system} = {
        agentImage = self.nixosConfigurations.agent.config.system.build.image;
        masterImage = self.nixosConfigurations.master.config.system.build.image;
        testImage = self.nixosConfigurations.test.config.system.build.image;

        agentInstallISO = self.nixosConfigurations.agent.config.system.build.isoImage;
        masterInstallISO = self.nixosConfigurations.master.config.system.build.isoImage;
        testInstallISO = self.nixosConfigurations.test.config.system.build.isoImage;
      };
    };
}