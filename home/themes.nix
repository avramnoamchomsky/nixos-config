{ pkgs, ... }:

let
  macTahoeGtk = pkgs.stdenvNoCC.mkDerivation {
    pname = "mac-tahoe-gtk-theme";
    version = "unstable-2026-08-13";

    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "MacTahoe-gtk-theme";
      rev = "26a6397583c8bc6302ac2de26cb356eb11190285";
      hash = "sha256-mkRMNpZ/wooBbrwTuXXNSL3DQlLBV7EgHJyjqjI+2yo=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/themes"
      tar -xJf release/MacTahoe-Dark-nord.tar.xz \
        -C "$out/share/themes"

      runHook postInstall
    '';

    meta = {
      description = "macOS Tahoe-like GTK theme";
      homepage = "https://github.com/vinceliuice/MacTahoe-gtk-theme";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
    };
  };

  macTahoeKvantum = pkgs.stdenvNoCC.mkDerivation {
    pname = "mac-tahoe-kvantum-theme";
    version = "unstable-2025-11-28";

    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "MacTahoe-kde";
      rev = "4c0ad8fe730d32c892c84ab0dcf9a104a6fd466d";
      hash = "sha256-6saJ9t1KZeIkCwR6ePKSnJxSsba0XRmck8g8/JDuuBE=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/Kvantum"
      cp -r Kvantum/MacTahoe "$out/share/Kvantum/"

      runHook postInstall
    '';

    meta = {
      description = "macOS Tahoe-like Kvantum theme";
      homepage = "https://github.com/vinceliuice/MacTahoe-kde";
      license = pkgs.lib.licenses.lgpl3Only;
      platforms = pkgs.lib.platforms.linux;
    };
  };

  qtctAppearance = {
    style = "kvantum";
    icon_theme = "Adwaita";
    standard_dialogs = "xdgdesktopportal";
  };
in
{
  home.packages = [ pkgs.nwg-look ];

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "MacTahoe-Dark-nord";
      package = macTahoeGtk;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";

    qt5ctSettings.Appearance = qtctAppearance;
    qt6ctSettings.Appearance = qtctAppearance;

    kvantum = {
      enable = true;
      themes = [ macTahoeKvantum ];
      settings.General.theme = "MacTahoeDark";
    };
  };
}
