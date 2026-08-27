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

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # Pinned to a mature revision whose helper has a smaller, reliable build
    # dependency graph on the current NixOS package set.
    sops-nix.url = "github:Mic92/sops-nix/e93ee1d900ad264d65e9701a5c6f895683433386";

    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-flatpak,
      sops-nix,
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
            nix-flatpak.nixosModules.nix-flatpak
            sops-nix.nixosModules.sops
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
