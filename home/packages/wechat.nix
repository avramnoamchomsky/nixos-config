{ pkgs }:

let
  version = "4.1.13.26";
in
# Reuse Nixpkgs' AppImage extraction, libtiff fix, and FHS runtime while
# updating WeChat independently of the system and other application pins.
pkgs.callPackage (pkgs.path + "/pkgs/by-name/we/wechat/linux.nix") {
  pname = "wechat";
  inherit version;

  src = pkgs.fetchurl {
    name = "wechat-${version}-x86_64.AppImage";
    # Upstream replaces this file in place; the hash pins the release.
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
    hash = "sha256-RSYYC8qYASh5FZmvEi/0eVACpXFaUQ9qZUgOK+aHQkQ=";
  };

  meta = pkgs.wechat.meta // {
    platforms = [ "x86_64-linux" ];
  };
}
