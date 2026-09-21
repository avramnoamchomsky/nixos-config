{ pkgs, ... }:

{
  # Keep the directly connected FPGA board on an isolated, route-less network.
  # The profile has no gateway or DNS and must never replace Wi-Fi's default
  # route.
  networking.networkmanager = {
    settings.main.no-auto-default = "enp3s0";

    ensureProfiles.profiles.fpga-tftp = {
      connection = {
        id = "fpga-tftp";
        type = "ethernet";
        interface-name = "enp3s0";
        autoconnect = true;
        autoconnect-priority = 100;
      };

      ipv4 = {
        method = "manual";
        addresses = "10.90.50.43/24";
        dns = "";
        dns-search = "";
        ignore-auto-dns = true;
        never-default = true;
      };

      ipv6.method = "disabled";
    };
  };

  services.atftpd = {
    enable = true;
    root = "/srv/tftp";
    extraOptions = [
      "--bind-address 10.90.50.43"
      "--verbose=5"
    ];
  };

  # atftpd has no read-only switch. Make the service's view of the TFTP root
  # read-only so write requests cannot create or replace artifacts. Loading a
  # NetworkManager profile is asynchronous, so retry until its address exists.
  systemd.services.atftpd = {
    requires = [ "NetworkManager-ensure-profiles.service" ];
    after = [ "NetworkManager-ensure-profiles.service" ];

    serviceConfig = {
      ReadOnlyPaths = [ "/srv/tftp" ];
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/tftp 0755 nobody nogroup -"
  ];

  # Linux 6.0 removed automatic conntrack-helper assignment, and NixOS rejects
  # autoLoadConntrackHelpers on this host's newer kernel. Trust only this
  # permanently dedicated, directly connected FPGA interface so TFTP's
  # dynamically allocated transfer port works without exposing it on Wi-Fi.
  networking.firewall.trustedInterfaces = [ "enp3s0" ];

  # Keep FPGA programming utilities and the firmware loader on the host. Vivado
  # runs in Distrobox, but udev and USB permissions remain host responsibilities.
  environment.systemPackages = with pkgs; [
    fxload
    openfpgaloader
  ];

  services.udev.extraRules = ''
    # AMD/Xilinx Platform Cable USB and compatible programmers.
    SUBSYSTEM=="usb", ATTR{idVendor}=="03fd", MODE="0660", GROUP="plugdev", TAG+="uaccess"

    # Digilent programmers, including the onboard JTAG interface used by many
    # Artix-7 development boards.
    SUBSYSTEM=="usb", ATTR{idVendor}=="1443", MODE="0660", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0660", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6011", MODE="0660", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6014", MODE="0660", GROUP="plugdev", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6015", MODE="0660", GROUP="plugdev", TAG+="uaccess"
  '';
}
