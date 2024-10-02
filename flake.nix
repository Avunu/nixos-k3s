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
        serverImage = self.nixosConfigurations.server.config.system.build.image;
      };

      nixosConfigurations = {

        agent = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./agent.nix
          ];
        };

        server = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./server.nix
          ];
        };

      };
    };
}