{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;

      makeImage =
        config:
        pkgs.nixos.lib.makeImage {
          inherit (config.system) build;
          inherit pkgs lib;
          format = "qcow2-compressed";
          installBootLoader = true;
        };
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
          modules = [ ./test.nix ];
        };
      };

      packages.${system} = {
        agentImage = makeImage self.nixosConfigurations.agent.config;
        masterImage = makeImage self.nixosConfigurations.master.config;
        testImage = makeImage self.nixosConfigurations.test.config;
      };
    };
}
