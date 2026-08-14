{ pkgs }:

let
  runtimeLibraries = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gcc-unwrapped.lib
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libgbm
    libglvnd
    libidn2
    libpulseaudio
    libva
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxtst
    nspr
    nss
    pango
    pipewire
    systemd
    vulkan-loader
    wayland
    zlib
  ];

  libraryPath = pkgs.lib.makeLibraryPath runtimeLibraries;
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "115-browser";
  version = "35.30.0";

  src = pkgs.fetchurl {
    url = "https://down.115.com/client/115pc/lin/115br_v35.30.0.deb";
    hash = "sha256-zyorduHyLkYF95/0XMwD6qPhX7xTHvwKmKmO9Dm7xUI=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    makeWrapper
    patchelf
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -d \
      "$out/bin" \
      "$out/libexec" \
      "$out/share/applications" \
      "$out/share/icons/hicolor/48x48/apps" \
      "$out/share/icons/hicolor/256x256/apps"

    cp -a usr/local/115Browser "$out/libexec/115-browser"

    patchelf \
      --set-interpreter ${pkgs.stdenv.cc.bintools.dynamicLinker} \
      --set-rpath "$out/libexec/115-browser:${libraryPath}" \
      "$out/libexec/115-browser/115Browser"

    patchelf \
      --set-interpreter ${pkgs.stdenv.cc.bintools.dynamicLinker} \
      --set-rpath "$out/libexec/115-browser:${libraryPath}" \
      "$out/libexec/115-browser/chrome_crashpad_handler"

    makeWrapper "$out/libexec/115-browser/115Browser" "$out/bin/115-browser" \
      --chdir "$out/libexec/115-browser" \
      --prefix LD_LIBRARY_PATH : "$out/libexec/115-browser:${libraryPath}" \
      --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.xdg-utils ]}" \
      --prefix XDG_DATA_DIRS : "${pkgs.adwaita-icon-theme}/share:${pkgs.gsettings-desktop-schemas}/share:${pkgs.gtk3}/share" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    cp usr/share/applications/115Browser.desktop \
      "$out/share/applications/115-browser.desktop"
    substituteInPlace "$out/share/applications/115-browser.desktop" \
      --replace-fail "Exec=sh /usr/local/115Browser/115.sh" "Exec=115-browser %U" \
      --replace-fail "Icon=/usr/local/115Browser/res/115Browser.png" "Icon=115-browser" \
      --replace-fail "Categories=Network;" "Categories=Network;WebBrowser;"
    echo "StartupWMClass=115Browser" >> "$out/share/applications/115-browser.desktop"

    install -Dm644 "$out/libexec/115-browser/product_logo_48.png" \
      "$out/share/icons/hicolor/48x48/apps/115-browser.png"
    install -Dm644 "$out/libexec/115-browser/res/115Browser.png" \
      "$out/share/icons/hicolor/256x256/apps/115-browser.png"

    runHook postInstall
  '';

  meta = {
    description = "Official 115 Browser desktop client";
    homepage = "https://pc.115.com/";
    license = pkgs.lib.licenses.unfree;
    mainProgram = "115-browser";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
  };
}
