{ pkgs, ... }:

let
  inherit (pkgs) yaziPlugins;
  # This revision includes the fix for archiving multiple selected files.
  compress = yaziPlugins.compress.overrideAttrs (old: {
    version = "0.6-unstable-2026-08-22";
    src = pkgs.fetchFromGitHub {
      owner = "KKV9";
      repo = "compress.yazi";
      rev = "80e5268ec74c7ac17d4d739e13a9958cba4c70d3";
      hash = "sha256-9cdA8D/TtwHcLqrtoyIixA0YJmTs+c8FSNrjxp8CYI0=";
    };
    # Yazi 26.5.6 exposes selected entries as URLs directly.
    postPatch = ''
      substituteInPlace main.lua --replace-fail 'tostring(u.url.parent)' 'tostring(u.parent)'
    '';
    meta = builtins.removeAttrs old.meta [ "changelog" ];
  });
  # Pin a revision compatible with the Yazi release in this flake.
  zoom = yaziPlugins.mkYaziPlugin {
    pname = "zoom.yazi";
    version = "0-unstable-2026-02-27";
    src = pkgs.fetchFromGitHub {
      owner = "yazi-rs";
      repo = "plugins";
      rev = "196281844b8cbcac658a59013e4805300c2d6126";
      hash = "sha256-pAkBlodci4Yf+CTjhGuNtgLOTMNquty7xP0/HSeoLzE=";
    };
  };
in
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

    plugins = {
      inherit compress zoom;
      inherit (yaziPlugins) mount;
      full-border = {
        package = yaziPlugins.full-border;
        setup = true;
        settings.set = "rounded";
      };
      git = {
        package = yaziPlugins.git;
        setup = true;
        settings.order = 1500;
      };
    };

    settings.plugin.prepend_fetchers = map (url: {
      inherit url;
      run = "git";
      group = "git";
    }) [ "*" "*/" ];

    keymap.mgr.prepend_keymap = [
      { on = [ "c" "a" "a" ]; run = "plugin compress"; desc = "Archive selected files"; }
      { on = [ "c" "a" "p" ]; run = "plugin compress -p"; desc = "Archive with a password"; }
      { on = [ "c" "a" "h" ]; run = "plugin compress -ph"; desc = "Archive with encrypted headers"; }
      { on = [ "c" "a" "l" ]; run = "plugin compress -l"; desc = "Archive with a custom compression level"; }
      { on = [ "c" "a" "u" ]; run = "plugin compress -phl"; desc = "Archive with all options"; }
      { on = "M"; run = "plugin mount"; desc = "Open the disk mount manager"; }
      { on = [ "g" "+" ]; run = "plugin zoom 1"; desc = "Zoom in on the image preview"; }
      { on = [ "g" "-" ]; run = "plugin zoom -1"; desc = "Zoom out of the image preview"; }
    ];
  };
}
