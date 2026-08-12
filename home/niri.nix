{ ... }:

{
  # Niri is installed and integrated by NixOS; Home Manager owns the
  # user-specific compositor configuration in its native KDL format.
  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
}
