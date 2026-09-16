{ pkgs, ... }:

{
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
