{ pkgs }:

let
  runtimeLibraries = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    atkmm
    cairo
    cairomm
    cups
    dbus
    expat
    fontconfig
    freetype
    gcc-unwrapped.lib
    gdk-pixbuf
    glib
    glibmm
    gtk2
    gtk3
    gtkmm2
    libappindicator-gtk3
    libdbusmenu-gtk3
    libdrm
    libgbm
    libglvnd
    libnotify
    libpulseaudio
    libsecret
    libsigcxx
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libxt
    libxtst
    nspr
    nss
    pango
    pangomm
    systemd # Chromium loads libudev dynamically during startup.
    zlib
  ];

  libraryPath = pkgs.lib.makeLibraryPath runtimeLibraries;
in
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "baidunetdisk";
  version = "8.7.0";

  src = pkgs.fetchurl {
    url = "https://pkg-ant.baidu.com/issue/netdisk/LinuxGuanjia/${finalAttrs.version}/baidunetdisk_${finalAttrs.version}_amd64.deb";
    hash = "sha256-7HHCrRFRYJ/Q2LhtlRhMC0V9bbWqGIYeCxX8I8z+Afc=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = runtimeLibraries ++ [ pkgs.adwaita-icon-theme ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -d "$out/bin" "$out/libexec" "$out/share"
    cp -a opt/baidunetdisk "$out/libexec/baidunetdisk"
    cp -a usr/share/applications usr/share/icons "$out/share/"

    # Upstream ships node-gyp build tools, including an unused Python 3.6
    # executable. Keep the compiled native modules, not these build artifacts.
    rm -rf "$out/libexec/baidunetdisk/resources/app.asar.unpacked/node_modules/"{windows-quiet-hours,windows-notification-state,macos-notification-state}/build

    # Keep the vendor's runtime desktop entries and context-menu command on
    # the same wrapper as the application-menu and browser URI launches.
    for entry in \
      "$out/share/applications/baidunetdisk.desktop" \
      "$out/libexec/baidunetdisk/baidunetdisk.desktop" \
      "$out/libexec/baidunetdisk/baidunetdiskv.desktop" \
      "$out/libexec/baidunetdisk/baiduNetdiskContext.conf"; do
      substituteInPlace "$entry" \
        --replace-fail "/opt/baidunetdisk/baidunetdisk" "$out/bin/baidunetdisk" \
        --replace-quiet " --no-sandbox" "" \
        --replace-quiet "Icon=$out/bin/baidunetdisk.svg" "Icon=baidunetdisk"
    done

    substituteInPlace "$out/share/applications/baidunetdisk.desktop" \
      --replace-fail "Name=baidunetdisk" "Name=Baidu Netdisk"
    cat >> "$out/share/applications/baidunetdisk.desktop" <<'EOF'
    Name[zh_CN]=百度网盘
    Name[zh_TW]=百度網盤
    EOF

    runHook postInstall
  '';

  postFixup = ''
    # Baidu's native transfer/browser libraries use GTK 2 alongside Electron's
    # GTK 3 runtime. Native modules inside app.asar also need this path because
    # autoPatchelf cannot inspect them; uiohook loads libXt and libXtst here.
    makeWrapper "$out/libexec/baidunetdisk/baidunetdisk" "$out/bin/baidunetdisk" \
      "''${gappsWrapperArgs[@]}" \
      --chdir "$out/libexec/baidunetdisk" \
      --prefix LD_LIBRARY_PATH : "$out/libexec/baidunetdisk:${libraryPath}" \
      --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}" \
      --set XMODIFIERS "@im=fcitx" \
      --set GTK_IM_MODULE "fcitx" \
      --set GDK_BACKEND "x11" \
      --add-flags "--no-sandbox --ozone-platform=x11"
  '';

  meta = {
    description = "Official Baidu Netdisk cloud storage desktop client";
    homepage = "https://pan.baidu.com/download";
    license = pkgs.lib.licenses.unfree;
    mainProgram = "baidunetdisk";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
  };
})
