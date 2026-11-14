{ config, desktopShell, lib, pkgs, ... }:

let
  # AccountsService limits copied icons to 1 MiB. Keep the original in Git
  # and build a smaller PNG without changing the image's composition.
  profileImage = pkgs.runCommand "dms-wood-whale-avatar.png" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    magick ${./dms/Wood_Whale.jpg} -resize 512x512 -strip "$out"
  '';

  wallpaperPath = "${config.xdg.userDirs.pictures}/Wallpapers/rose-wallpaper-3840x2160-vibrant-hues-pink-blossoms-454.jpg";
  wallpaperSession = pkgs.writeText "dms-wallpaper-session.json" (builtins.toJSON {
    wallpaperPathLight = wallpaperPath;
    wallpaperPathDark = wallpaperPath;
  });
  # The upstream Niri template enables Num Lock. Keep that default in DMS
  # settings so it can be switched off from the keyboard settings page.
  stockInput = pkgs.writeText "dms-stock-input.json" (builtins.toJSON {
    keyboardNumlock = true;
  });
in

{
  # Start with DMS 2 defaults once. Move both directory names out of the way
  # so the upstream migration cannot import old preferences on first launch.
  home.activation.dmsSettings = lib.hm.dag.entryBetween [ "reloadSystemd" ] [ "linkGeneration" ] ''
    if [[ ! -v DRY_RUN ]]; then
      dmsConfigHome=${lib.escapeShellArg config.xdg.configHome}
      dmsStateHome=${lib.escapeShellArg config.xdg.stateHome}
      dmsCacheHome=${lib.escapeShellArg config.xdg.cacheHome}
      dmsDataHome=${lib.escapeShellArg config.xdg.dataHome}
      dmsResetStamp="$dmsStateHome/dms-stock-v2"
      if [[ ! -e "$dmsResetStamp" ]]; then
        for base in "$dmsConfigHome" "$dmsStateHome" "$dmsCacheHome" "$dmsDataHome"; do
          for name in dms DankMaterialShell; do
            if [[ -e "$base/$name" || -L "$base/$name" ]]; then
              backup=$(mktemp -d "$base/dms-before-stock.XXXXXX")
              mv -T -- "$base/$name" "$backup/$name"
            fi
          done
        done
        install -Dm0600 ${stockInput} "$dmsConfigHome/dms/settings.json"
        install -Dm0600 ${wallpaperSession} "$dmsStateHome/dms/session.json"
        touch "$dmsResetStamp"
      fi
    fi
  '';

  # Keep the wallpaper collection declarative while exposing it at the
  # conventional writable-user-data location expected by DMS file pickers.
  home.file."Pictures/Wallpapers".source = ./wallpapers;

  # DMS reads the account icon from AccountsService, not settings.json.
  home.activation.dmsProfileImage = lib.hm.dag.entryAfter [ "dmsSettings" ] ''
    account_path=$(${pkgs.systemd}/bin/busctl --system --json=short call \
      org.freedesktop.Accounts /org/freedesktop/Accounts \
      org.freedesktop.Accounts FindUserByName s \
      ${lib.escapeShellArg config.home.username} | ${pkgs.jq}/bin/jq -r '.data[0]')

    run ${pkgs.systemd}/bin/busctl --system call \
      org.freedesktop.Accounts "$account_path" \
      org.freedesktop.Accounts.User SetIconFile s ${profileImage}

    # Refresh a running shell so its cached avatar changes immediately.
    if ${pkgs.systemd}/bin/systemctl --user --quiet is-active dms.service; then
      PATH=${lib.makeBinPath [ desktopShell.quickshell ]} \
        run ${lib.getExe desktopShell.package} ipc call profile setImage ${profileImage} \
        || warnEcho "DMS will pick up the updated account icon the next time it starts."
    fi
  '';
}
