{ pkgs }:

let
  # Avalonia, WebKitGTK, and .NET load several libraries through dlopen/PInvoke.
  runtimeLibraries = with pkgs; [
    alsa-lib
    dbus
    fontconfig
    freetype
    gcc-unwrapped.lib
    glib
    gtk3
    libglvnd
    libice
    libkrb5
    libnotify
    libpulseaudio
    libsecret
    libsm
    libsoup_3
    libva
    libx11
    libxcursor
    libxext
    libxfixes
    libxi
    libxrandr
    lttng-ust_2_12
    openssl
    vulkan-loader
    webkitgtk_4_1
    zlib
  ];

  libraryPath = pkgs.lib.makeLibraryPath runtimeLibraries;
in
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "115-life";
  version = "37.3.1";

  src = pkgs.fetchurl {
    url = "https://down.115.com/client/115pc/lin/115Life_${finalAttrs.version}.deb";
    hash = "sha256-44E+Kvg8/+7X4xYFga7/6wfSyzPqjzA/tWi7VwgskxU=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = runtimeLibraries;

  dontConfigure = true;
  dontBuild = true;
  # Stripping the self-contained .NET app can damage its embedded metadata.
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
    cp -a opt/115life "$out/libexec/115-life"
    cp -a usr/share/applications usr/share/icons usr/share/doc "$out/share/"

    # .NET loads the app-local ICU suffix, but ICU's own ELF dependencies use
    # its major-version SONAME. Upstream omits these Linux loader aliases.
    for component in data i18n uc; do
      ln -s "libicu$component.so.72.1.0.3" \
        "$out/libexec/115-life/libicu$component.so.72"
    done

    substituteInPlace "$out/share/applications/life115.desktop" \
      --replace-fail 'Exec="/opt/115life/Life115" %U' "Exec=$out/bin/115-life %U"

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper "$out/libexec/115-life/Life115" "$out/bin/115-life" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "$out/libexec/115-life:${libraryPath}" \
      --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.desktop-file-utils pkgs.xdg-utils ]}"
    ln -s 115-life "$out/bin/115life"
  '';

  meta = {
    description = "Official 115 Life cloud storage desktop client";
    homepage = "https://115.com/115/T984564.html";
    license = pkgs.lib.licenses.unfree;
    mainProgram = "115-life";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
  };
})
