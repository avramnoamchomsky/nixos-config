{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # Improve game performance and provide a nested compositor for games that
  # need more predictable fullscreen or resolution handling under Wayland.
  programs.gamemode.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Install udev rules for Steam controllers and related hardware.
  hardware.steam-hardware.enable = true;
}
