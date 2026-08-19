{ ... }:

{
  # Keep fast compressed swap for ordinary memory pressure. Zram is not a
  # hibernation target because its contents disappear when power is removed.
  zramSwap.enable = true;

  # NixOS creates this as a Btrfs-compatible NOCOW swap file. It lives inside
  # the encrypted root filesystem, so the hibernation image is encrypted too.
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 72 * 1024;
    }
  ];

  # The systemd initrd records the selected swap file and its current Btrfs
  # offset in the HibernateLocation EFI variable, avoiding a hard-coded
  # resume_offset that could become stale if the file is recreated.
  boot.initrd.systemd.enable = true;

  # Both s2idle and S4 currently leave integrated AMD SoC devices in an
  # unrecoverable state. Keep every system sleep path disabled until an
  # upstream kernel or firmware fix is available.
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
