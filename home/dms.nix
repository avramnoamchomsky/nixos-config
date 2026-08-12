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
  # These files deliberately contain preferences only: histories, device pins,
  # display state, and other runtime data do not belong in Git.
  xdg.configFile."DankMaterialShell/settings.json".text = builtins.toJSON {
    configVersion = 5;

    currentThemeCategory = "dynamic";
    currentThemeName = "dynamic";
    matugenScheme = "scheme-tonal-spot";

    fontFamily = "Inter";
    fontScale = 1;
    fontWeight = 400;
    iconTheme = "System Default";
    cornerRadius = 12;
    animationSpeed = 1;

    blurEnabled = true;
    gtkThemingEnabled = false;

    # Niri is owned directly by Home Manager; DMS must not generate a second
    # compositor configuration tree under ~/.config/niri/dms.
    matugenTemplateNiri = false;

    lockAtStartup = false;
    lockBeforeSuspend = false;
    lockScreenShowDate = true;
    lockScreenShowMediaPlayer = true;
    lockScreenShowPowerActions = true;
    lockScreenPowerOffMonitorsOnLock = false;
    loginctlLockIntegration = true;

    acLockTimeout = 0;
    batteryLockTimeout = 0;
    acSuspendTimeout = 0;
    batterySuspendTimeout = 0;

    enableFprint = false;
    enableU2f = false;

    # Preserve the current bar layout while excluding usage and device state.
    barConfigs = [
      {
        id = "default";
        name = "Main Bar";
        enabled = true;
        position = 0;
        screenPreferences = [ "all" ];
        showOnLastDisplay = true;

        leftWidgets = [
          "launcherButton"
          "workspaceSwitcher"
          "focusedWindow"
        ];
        centerWidgets = [
          "music"
          "clock"
          "weather"
        ];
        rightWidgets = [
          {
            id = "network_speed_monitor";
            enabled = true;
          }
          {
            id = "clipboard";
            enabled = true;
          }
          {
            id = "cpuUsage";
            enabled = true;
          }
          {
            id = "memUsage";
            enabled = true;
          }
          {
            id = "cpuTemp";
            enabled = true;
            minimumWidth = true;
          }
          {
            id = "notificationButton";
            enabled = true;
          }
          {
            id = "systemTray";
            enabled = true;
          }
          {
            id = "controlCenterButton";
            enabled = true;
          }
          {
            id = "battery";
            enabled = true;
          }
        ];

        spacing = 4;
        innerPadding = 4;
        bottomGap = 0;
        transparency = 0;
        widgetTransparency = 1;
        squareCorners = false;
        noBackground = false;
        maximizeWidgetIcons = false;
        maximizeWidgetText = false;
        removeWidgetPadding = false;
        widgetPadding = 8;
        gothCornersEnabled = false;
        gothCornerRadiusOverride = false;
        gothCornerRadiusValue = 12;
        borderEnabled = false;
        borderColor = "surfaceText";
        borderOpacity = 1;
        borderThickness = 1;
        widgetOutlineEnabled = false;
        widgetOutlineColor = "primary";
        widgetOutlineOpacity = 1;
        widgetOutlineThickness = 1;
        fontScale = 1;
        iconScale = 1;
        autoHide = false;
        autoHideDelay = 250;
        showOnWindowsOpen = false;
        openOnOverview = true;
        visible = true;
        popupGapsAuto = true;
        popupGapsManual = 4;
        maximizeDetection = true;
        scrollEnabled = true;
        scrollXBehavior = "column";
        scrollYBehavior = "workspace";
        shadowIntensity = 0;
        shadowOpacity = 60;
        shadowColorMode = "text";
        shadowCustomColor = "#000000";
        clickThrough = false;
      }
    ];
  };

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
