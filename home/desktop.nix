{ ... }:

{
  # Stable desktop preferences. Other dconf keys remain mutable.
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    "org/gnome/nautilus/preferences".show-delete-permanently = true;
    "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
  };

  # MControlCenter's window geometry is deliberately omitted; only hardware
  # behaviour belongs in Git.
  xdg.configFile."MControlCenter.conf" = {
    force = true;
    text = ''
      [Settings]
      UserMode=super_battery_mode
      fan1SpeedSettings=30|40|40|50|57|65|70
      fan1TempSettings=50|57|64|71|78|85
      fan2SpeedSettings=20|48|55|62|68|77|85
      fan2TempSettings=55|60|65|70|75|80
      fanModeAdvanced=true
    '';
  };
}
