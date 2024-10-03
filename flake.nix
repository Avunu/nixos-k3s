{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      lib = nixpkgs.lib;
    in
    {
      packages.${system} = {
        agentImage = self.nixosConfigurations.agent.config.system.build.image;
        masterImage = self.nixosConfigurations.master.config.system.build.image;
      };

      nixosConfigurations = {

        agent = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs; };
          modules = [
            ./agent.nix
          ];
        };

        master = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs; };
          modules = [
            ./master.nix
          ];
        };

      };
    };
}