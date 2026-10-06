{ config, lib, pkgs, ... }:

let
  # AccountsService limits copied icons to 1 MiB. Keep the original in Git
  # and build a smaller PNG without changing the image's composition.
  profileImage = pkgs.runCommand "dms-wood-whale-avatar.png" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    magick ${./dms/Wood_Whale.jpg} -resize 512x512 -strip "$out"
  '';

  # DMS keeps both preferences and volatile state in session.json. This
  # fragment is merged at activation time so wallpaper, devices, histories,
  # and launcher state remain writable and are not copied into Git.
  sessionPreferences = pkgs.writeText "dms-session-preferences.json" (
    builtins.toJSON {
      configVersion = 3;

      isLightMode = false;
      themeModeAutoEnabled = false;
      themeModeAutoMode = "time";
      themeModeStartHour = 18;
      themeModeStartMinute = 0;
      themeModeEndHour = 6;
      themeModeEndMinute = 0;
      themeModeShareGammaSettings = true;

      nightModeEnabled = false;
      nightModeAutoEnabled = false;
      nightModeAutoMode = "time";
      nightModeStartHour = 18;
      nightModeStartMinute = 0;
      nightModeEndHour = 6;
      nightModeEndMinute = 0;
      nightModeTemperature = 4500;
      nightModeHighTemperature = 6500;
      nightModeUseIPLocation = false;

      # DMS derives its wallpaper cycling directory from the selected file.
      wallpaperPath = "${config.xdg.userDirs.pictures}/Wallpapers/rose-wallpaper-3840x2160-vibrant-hues-pink-blossoms-454.jpg";
    }
  );
in

{
  # DMS itself and its user service are provided by the native NixOS module.
  # The complete reviewed settings snapshot is Git-owned and read-only.
  xdg.configFile."DankMaterialShell/settings.json".source = ./dms/settings.json;

  # Keep the wallpaper collection declarative while exposing it at the
  # conventional writable-user-data location expected by DMS file pickers.
  home.file."Pictures/Wallpapers".source = ./wallpapers;

  # DMS reads the account icon from AccountsService, not settings.json.
  home.activation.dmsProfileImage = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    account_path=$(${pkgs.systemd}/bin/busctl --system --json=short call \
      org.freedesktop.Accounts /org/freedesktop/Accounts \
      org.freedesktop.Accounts FindUserByName s \
      ${lib.escapeShellArg config.home.username} | ${pkgs.jq}/bin/jq -r '.data[0]')

    run ${pkgs.systemd}/bin/busctl --system call \
      org.freedesktop.Accounts "$account_path" \
      org.freedesktop.Accounts.User SetIconFile s ${profileImage}

    # Refresh a running shell so its cached avatar changes immediately.
    if ${pkgs.systemd}/bin/systemctl --user --quiet is-active dms.service; then
      run ${pkgs.dms-shell}/bin/dms ipc call profile setImage ${profileImage}
    fi
  '';

  xdg.configFile."DankMaterialShell/clsettings.json".text = builtins.toJSON {
    disabled = false;
    maxHistory = 100;
    maxEntrySize = 20971520;
    maxPinned = 25;
    autoClearDays = 0;
    clearAtStartup = false;
  };

  home.activation.dmsSessionPreferences = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state_dir=${lib.escapeShellArg "${config.xdg.stateHome}/DankMaterialShell"}
    session_file="$state_dir/session.json"
    session_tmp="$state_dir/session.json.home-manager-tmp"

    if [ -n "''${DRY_RUN_CMD:-}" ]; then
      echo "Would merge declarative DMS session preferences into $session_file"
    else
      mkdir -p "$state_dir"

      if [ -s "$session_file" ]; then
        if ! ${pkgs.jq}/bin/jq -e 'type == "object"' "$session_file" >/dev/null 2>&1; then
          echo "Refusing to overwrite invalid DMS session data: $session_file" >&2
          exit 1
        fi
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$session_file" ${sessionPreferences} > "$session_tmp"
      else
        ${pkgs.jq}/bin/jq . ${sessionPreferences} > "$session_tmp"
      fi

      mv "$session_tmp" "$session_file"
    fi
  '';
}
