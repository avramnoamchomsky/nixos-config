{ config, lib, pkgs, ... }:

let
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
    }
  );
in

{
  # DMS itself and its user service are provided by the native NixOS module.
  # The complete reviewed settings snapshot is Git-owned and read-only.
  xdg.configFile."DankMaterialShell/settings.json".source = ./dms/settings.json;

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
