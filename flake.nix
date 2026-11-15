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

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      dms,
      nix-flatpak,
      sops-nix,
      lanzaboote,
      codex-desktop-linux,
      msime,
      ...
    }:
    let
      system = "x86_64-linux";

      # Keep DMS and Quickshell on the same Qt package set.
      desktopShell = {
        package = dms.packages.${system}.default;
        quickshell = dms.inputs.nixpkgs.legacyPackages.${system}.quickshell;
        source = dms.outPath;
      };

      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.Pisces =
        nixpkgs.lib.nixosSystem {
          inherit system;

          # Make an unstable package set available to NixOS and Home Manager.
          # This does NOT move the NixOS system itself to unstable.
          specialArgs = { inherit desktopShell unstablePkgs; };

          modules = [
            ./system
            dms.nixosModules.default
            codex-desktop-linux.nixosModules.default
            msime.nixosModules.default
            (
              { pkgs, ... }:
              {
                programs.msime.package = (pkgs.extend msime.overlays.default).msime-fcitx5.overrideAttrs {
                  # The candidate canvas tests need fonts inside the build sandbox.
                  FONTCONFIG_FILE = pkgs.makeFontsConf {
                    fontDirectories = [ pkgs.dejavu_fonts pkgs.noto-fonts-cjk-sans ];
                  };
                  CTEST_OUTPUT_ON_FAILURE = "1";
                };
              }
            )
            nix-flatpak.nixosModules.nix-flatpak
            sops-nix.nixosModules.sops
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager

            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit desktopShell unstablePkgs; };
                users.chomsky = ./home;
              };
            }
          ];
        };
    };
}
