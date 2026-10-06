{ pkgs, ... }:

let
  life115 = import ./packages/115-life.nix { inherit pkgs; };
in
{
  home.packages = [ life115 ];

  # Upstream registers this local desktop ID at startup. Keep it pointing at
  # the wrapper, which supplies the NixOS runtime libraries and GTK resources.
  xdg.dataFile."applications/life115.desktop" = {
    source = "${life115}/share/applications/life115.desktop";
    force = true;
  };

  xdg.mimeApps.defaultApplications."x-scheme-handler/life115" = [ "life115.desktop" ];
}
