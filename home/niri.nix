{ config, pkgs, ... }:

{
  # Niri is installed and integrated by NixOS; Home Manager owns the complete
  # user-specific compositor configuration in its native KDL format.
  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;

  # DMS generates optional Niri fragments unconditionally. Since none are
  # included by the Git-owned config, remove them after each recreation.
  systemd.user.services.remove-unused-dms-niri-fragments = {
    Unit.Description = "Remove unused DMS-generated Niri fragments";

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "remove-unused-dms-niri-fragments" ''
        sleep 1
        rm -rf -- ${config.xdg.configHome}/niri/dms
      '';
    };
  };

  systemd.user.paths.remove-unused-dms-niri-fragments = {
    Unit.Description = "Watch for unused DMS-generated Niri fragments";
    Path.PathExists = "${config.xdg.configHome}/niri/dms";
    Install.WantedBy = [ "default.target" ];
  };
}
