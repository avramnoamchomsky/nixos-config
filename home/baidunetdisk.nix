{ pkgs, ... }:

let
  baiduNetdisk = import ../packages/baidunetdisk.nix { inherit pkgs; };
in
{
  home.packages = [ baiduNetdisk ];

  xdg.mimeApps.defaultApplications."x-scheme-handler/baiduyunguanjia" = [ "baidunetdisk.desktop" ];
}
