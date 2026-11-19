{ config, pkgs, ... }:

{
  # ============================================================
  # MSI Alpha 17 C7VF embedded-controller support
  # ============================================================

  # Out-of-tree msi-ec module packaged for the selected kernel.
  boot.extraModulePackages = [
    config.boot.kernelPackages.msi-ec
  ];

  boot.kernelModules = [
    "msi-ec"

    # MControlCenter also uses ec_sys for temperatures and
    # custom fan curves.
    "ec_sys"
  ];

  boot.extraModprobeConfig = ''
    # ----------------------------------------------------------
    # MSI-EC firmware profile
    # ----------------------------------------------------------
    #
    # Actual EC:
    #   17KKIMS1.115
    #
    # Force the packaged msi-ec driver to use the known-working:
    #   17KKIMS1.114
    #
    # .115 has been tested with the .114 EC layout on this
    # specific machine.
    options msi_ec firmware=17KKIMS1.114

    # ----------------------------------------------------------
    # ec_sys
    # ----------------------------------------------------------

    # Required by MControlCenter for fan-curve writes.
    options ec_sys write_support=1
  '';

  # MSI laptop control GUI.
  environment.systemPackages = [
    pkgs.mcontrolcenter
  ];

  # Register MControlCenter's privileged helper and D-Bus policy.
  services.dbus.packages = [
    pkgs.mcontrolcenter
  ];
}
