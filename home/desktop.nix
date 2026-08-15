{ config, pkgs, ... }:

{
  # UDisks provides mounting; udiskie reacts to removable-media events in the
  # minimal Niri session, where no desktop environment starts an automounter.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "never";
  };

  # GLib cannot infer a terminal emulator in the minimal Niri session. Keep
  # the upstream desktop ID so existing MIME associations continue to work,
  # but launch Neovim explicitly inside Ghostty.
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    comment = "Edit text files in Neovim using Ghostty";
    exec = "${pkgs.ghostty}/bin/ghostty -e ${config.programs.neovim.finalPackage}/bin/nvim %F";
    icon = "nvim";
    terminal = false;
    startupNotify = false;
    categories = [
      "Utility"
      "TextEditor"
      "Development"
    ];
    mimeType = [
      "application/json"
      "application/x-shellscript"
      "text/english"
      "text/plain"
      "text/x-c"
      "text/x-c++"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-java"
      "text/x-makefile"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
    ];
    settings.Keywords = "Text;editor;";
  };

  # Stable desktop preferences. Other dconf keys remain mutable.
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    "org/gnome/nautilus/preferences".show-delete-permanently = true;
    "org/gtk/gtk4/settings/file-chooser".show-hidden = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "com.google.Chrome.desktop" ];
      "x-scheme-handler/codex" = [ "codex-desktop.desktop" ];
      "x-scheme-handler/http" = [ "com.google.Chrome.desktop" ];
      "x-scheme-handler/https" = [ "com.google.Chrome.desktop" ];
    };
  };

  # Take ownership of the mutable MIME files that predate Home Manager.
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;

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
