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

  # Offer only the two independent modes used on this laptop. Its firmware
  # exposes s2idle but not ACPI S3/deep sleep.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = true;
    AllowHibernation = true;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
    MemorySleepMode = "s2idle";
  };
}
