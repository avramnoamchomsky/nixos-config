{ config, lib, pkgs, ... }:

let
  ghostDownloader = pkgs.callPackage ./packages/ghost-downloader.nix { };
  desktopId = "io.github.xiaoyouchr.GhostDownloader";
  initialConfig = pkgs.writeText "ghost-downloader-initial-config.json" (builtins.toJSON {
    Software.CheckUpdateAtStartUp = false;
    GeneralDownload.shouldVerifySsl = true;
  });
in
{
  home.packages = [ ghostDownloader ];

  # Upstream also registers this exact local desktop file. Create it with the
  # Nix wrapper so URL registration keeps a working entry outside the FHS env.
  xdg.dataFile."applications/${desktopId}.desktop".source =
    "${ghostDownloader}/share/applications/${desktopId}.desktop";

  xdg.mimeApps.defaultApplications."x-scheme-handler/ghostdownloader" = [ "${desktopId}.desktop" ];

  # Seed only a fresh install. Settings remain writable in the application;
  # application binaries are updated by changing the pinned Nix package.
  home.activation.ghostDownloaderConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    install -d -m 700 ${lib.escapeShellArg "${config.xdg.dataHome}/GhostDownloader"}
    if [ ! -e ${lib.escapeShellArg "${config.xdg.dataHome}/GhostDownloader/UserConfig.json"} ]; then
      install -m 600 ${initialConfig} ${lib.escapeShellArg "${config.xdg.dataHome}/GhostDownloader/UserConfig.json"}
    fi
  '';
}
