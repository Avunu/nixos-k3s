{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-generators,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;

      makeImage =
        config: format:
        nixos-generators.nixosGenerate {
          inherit pkgs;
          format = format;
          modules = [
            config
            {
              imports = [ "${pkgs.path}/nixos/modules/profiles/qemu-guest.nix" ];
            }
          ];
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
        agentImage = makeImage self.nixosConfigurations.agent.config "qcow";
        masterImage = makeImage self.nixosConfigurations.master.config "qcow";
        testImage = makeImage self.nixosConfigurations.test.config "qcow";

        agentInstallISO = makeImage self.nixosConfigurations.agent.config "iso";
        masterInstallISO = makeImage self.nixosConfigurations.master.config "iso";
        testInstallISO = makeImage self.nixosConfigurations.test.config "iso";
      };
    };
}
