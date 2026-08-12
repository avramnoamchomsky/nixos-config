{
  description = "Pisces NixOS configuration";

  inputs = {
    # Main system stays on NixOS 26.05 stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Only for fast-moving applications such as QQ.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      codex-desktop-linux,
      ...
    }:
    let
      system = "x86_64-linux";

      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.pisces =
        nixpkgs.lib.nixosSystem {
          inherit system;

          # Make an unstable package set available to NixOS and Home Manager.
          # This does NOT move the NixOS system itself to unstable.
          specialArgs = { inherit unstablePkgs; };

          modules = [
            ./system
            codex-desktop-linux.nixosModules.default
            home-manager.nixosModules.home-manager

            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit unstablePkgs; };
                users.chomsky = ./home;
              };
            }
          ];
        };
    };
}
