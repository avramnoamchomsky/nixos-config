{ pkgs }:

let
  runtimeLibraries = with pkgs; [
    ayatana-ido
    gtk3
    libayatana-appindicator
    libayatana-indicator
    libdbusmenu
    libdbusmenu-gtk3
    libepoxy
    libglvnd
    libsecret
    mpv-unwrapped
    zlib
  ];
in
pkgs.stdenv.mkDerivation {
  pname = "sylvakru";
  version = "3.6.0";

  src = pkgs.fetchurl {
    url = "https://github.com/AfalpHy/sylvakru/releases/download/v3.6.0/sylvakru-3.6.0-linux-amd64.deb";
    hash = "sha256-QQA5W9ut48CeDAdt8h+7VTlRUZm69uQ5/3bDKY+6rqA=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = runtimeLibraries;

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  autoPatchelfIgnoreMissingDeps = [ "libjvm.so" ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/bin" "$out/lib" "$out/share"
    cp -a usr/lib/sylvakru "$out/lib/sylvakru"
    cp -a usr/share/applications "$out/share/applications"
    cp -a usr/share/icons "$out/share/icons"

    makeWrapper "$out/lib/sylvakru/sylvakru" "$out/bin/sylvakru" \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runtimeLibraries}" \
      --prefix XDG_DATA_DIRS : "${pkgs.adwaita-icon-theme}/share:${pkgs.gsettings-desktop-schemas}/share:${pkgs.gtk3}/share"

    runHook postInstall
  '';

  meta = {
    description = "Local and self-hosted music player";
    homepage = "https://github.com/AfalpHy/sylvakru";
    license = pkgs.lib.licenses.asl20;
    mainProgram = "sylvakru";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
  };
}
