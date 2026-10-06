{ ... }:

{
  # Use compressed RAM swap for ordinary memory pressure. Hibernation is
  # intentionally disabled, so no disk-backed swap file is needed.
  zramSwap.enable = true;

  # Keep the existing initrd boot implementation.
  boot.initrd.systemd.enable = true;

  # Both s2idle and S4 currently leave integrated AMD SoC devices in an
  # unrecoverable state. Keep every system sleep path disabled; hibernation
  # is no longer planned.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

  # Closing the lid must not request a disabled or unreliable sleep state.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
