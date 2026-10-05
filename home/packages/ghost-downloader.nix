{ lib, appimageTools, fetchurl }:

let
  pname = "ghost-downloader";
  version = "4.3.7";
  src = fetchurl {
    url = "https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/download/v${version}/Ghost-Downloader-v${version}-Linux-x86_64.AppImage";
    hash = "sha256-N2CYcJXIOeBWNn9LRxnCIzPVLI7O8ROBSU2rfXRMy6A=";
  };
  contents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.ffmpeg-headless pkgs.xdg-utils ];

  # Use the AppImage's bundled Qt plugins instead of the desktop's Qt paths.
  profile = ''
    unset QT_PLUGIN_PATH QT_QPA_PLATFORM_PLUGIN_PATH QML2_IMPORT_PATH QT_STYLE_OVERRIDE
  '';

  extraInstallCommands = ''
    install -Dm644 ${contents}/ghost-downloader.desktop \
      "$out/share/applications/io.github.xiaoyouchr.GhostDownloader.desktop"
    substituteInPlace "$out/share/applications/io.github.xiaoyouchr.GhostDownloader.desktop" \
      --replace-fail 'Exec=ghost-downloader' "Exec=$out/bin/ghost-downloader %U"
    echo 'MimeType=x-scheme-handler/ghostdownloader;' \
      >> "$out/share/applications/io.github.xiaoyouchr.GhostDownloader.desktop"
    echo 'StartupWMClass=Ghost-Downloader-3' \
      >> "$out/share/applications/io.github.xiaoyouchr.GhostDownloader.desktop"
    install -Dm644 ${contents}/usr/share/icons/hicolor/256x256/apps/ghost-downloader.png \
      "$out/share/icons/hicolor/256x256/apps/ghost-downloader.png"
  '';

  meta = {
    description = "Download manager for files, videos, torrents, and streams";
    homepage = "https://github.com/XiaoYouChR/Ghost-Downloader-3";
    license = lib.licenses.gpl3Only;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
