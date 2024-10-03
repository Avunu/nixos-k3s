{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-k3s = {
      url = "github:Avunu/nixos-k3s";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-k3s,
    }:
    {
      nixosConfigurations = {
        ${builtins.readFile "/etc/hostname"} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-k3s.nixosModules.master
          ];
        };
      };
    };
}
