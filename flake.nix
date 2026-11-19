{
  description = "NixOS host configurations";

  inputs = {
    # Main system stays on NixOS 26.05 stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Only for fast-moving applications such as QQ.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms.url = "github:duxlabs-dev/dux-shell/v2.1.2";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # Pinned to a mature revision whose helper has a smaller, reliable build
    # dependency graph on the current NixOS package set.
    sops-nix.url = "github:Mic92/sops-nix/e93ee1d900ad264d65e9701a5c6f895683433386";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";

    msime = {
      url = "github:metasequoiaime/msime/21aacdded83643576e4a0318803e34b6e7d258bc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }: {
    nixosConfigurations.Pisces = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/Pisces ];
    };
  };
}
