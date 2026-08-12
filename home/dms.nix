{ ... }:

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
}
