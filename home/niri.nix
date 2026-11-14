{ config, desktopShell, lib, pkgs, ... }:

let
  defaults = "${desktopShell.source}/core/internal/config/embedded";
  upstreamConfig = builtins.readFile "${defaults}/niri.kdl";

  # Move the release's app rules and Alt+Tab bindings into editable fragments.
  # Remove its unconditional Num Lock flag so DMS's keyboard toggle works.
  withWindowRules = lib.splitString "\n// Window rules let you adjust behavior" upstreamConfig;
  withDebug = lib.splitString "\ndebug {" (builtins.elemAt withWindowRules 1);
  withRecentWindows = lib.splitString "\n// Override to disable super+tab\n" (builtins.elemAt withDebug 1);
  withIncludes = lib.splitString "\n// Include dms files\n" (builtins.elemAt withRecentWindows 1);

  stockBinds = pkgs.writeText "dms-niri-stock-binds.kdl" (
    lib.replaceStrings [ "{{TERMINAL_COMMAND}}" ] [ "ghostty" ] (
      builtins.readFile "${defaults}/niri-binds.kdl"
    )
    + "\n${builtins.head withIncludes}"
  );
  stockWindowRules = pkgs.writeText "dms-niri-stock-windowrules.kdl" (
    "// Window rules let you adjust behavior" + builtins.head withDebug + "\n"
  );
in
{
  # Only the primary local console launches the desktop. Replacing the
  # shell returns to the login prompt when Niri exits or fails.
  programs.fish.loginShellInit = ''
    if status is-interactive; and test "$(${pkgs.coreutils}/bin/tty)" = /dev/tty1
      and test -z "$SSH_CONNECTION"; and test -z "$WAYLAND_DISPLAY"; and test -z "$DISPLAY"
      exec ${pkgs.niri}/bin/niri-session
    end
  '';

  xdg.configFile."niri/resize-presets.kdl".source = ./niri/resize-presets.kdl;
  xdg.configFile."niri/config.kdl".text =
    lib.replaceStrings
      [ "        // Enable numlock on startup, omitting this setting disables it.\n        numlock\n" ]
      [ "" ]
      (builtins.head withWindowRules)
    + "\ndebug {${builtins.head withRecentWindows}\n"
    + lib.replaceStrings
      [ ''include optional=true "dms/layout.kdl"'' ]
      [ "include optional=true \"dms/windowrules.kdl\"\ninclude optional=true \"dms/layout.kdl\"" ]
      (builtins.elemAt withIncludes 1)
    + ''
      include optional=true "dms/wpblur.kdl"
      include "resize-presets.kdl"
    '';

  # Wait for Home Manager to stop the old unit that deleted niri/dms.
  home.activation.dmsNiriDefaults = lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
    if [[ ! -v DRY_RUN ]]; then
      dmsNiriDir=${lib.escapeShellArg "${config.xdg.configHome}/niri/dms"}
      dmsNiriResetStamp=${lib.escapeShellArg "${config.xdg.stateHome}/niri/dms-stock-v2"}

      if [[ ! -e "$dmsNiriResetStamp" ]]; then
        if [[ -e "$dmsNiriDir" || -L "$dmsNiriDir" ]]; then
          backup=$(mktemp -d "$dmsNiriDir-before-stock.XXXXXX")
          mv -T -- "$dmsNiriDir" "$backup/dms"
        fi
        install -Dm0644 ${stockBinds} "$dmsNiriDir/binds.kdl"
        install -m0644 ${stockWindowRules} "$dmsNiriDir/windowrules.kdl"
        for fragment in colors layout alttab input; do
          install -m0644 ${defaults}/niri-"$fragment".kdl "$dmsNiriDir/$fragment.kdl"
        done
        install -m0644 ${desktopShell.source}/quickshell/Services/niri-wpblur.kdl "$dmsNiriDir/wpblur.kdl"
        touch "$dmsNiriDir/outputs.kdl" "$dmsNiriDir/cursor.kdl"
        install -D /dev/null "$dmsNiriResetStamp"
      fi
    fi
  '';
}
