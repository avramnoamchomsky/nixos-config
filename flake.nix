{
  description = "Pisces NixOS configuration";

  inputs = {
    # Main system stays on NixOS 26.05 stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Only for fast-moving applications such as QQ.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      codex-desktop-linux,
      ...
    }:
    {
      nixosConfigurations.pisces =
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # Make an unstable package set available to configuration.nix.
          # This does NOT move the NixOS system itself to unstable.
          specialArgs = {
            unstablePkgs = import nixpkgs-unstable {
              system = "x86_64-linux";

              config = {
                allowUnfree = true;
              };
            };
          };

          modules = [
	    codex-desktop-linux.nixosModules.default
            ./configuration.nix
          ];
        };
    };
}
