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
    associations.added = config.xdg.mimeApps.defaultApplications;
    defaultApplications = {
      "application/pdf" = [ "com.google.Chrome.desktop" ];
      "application/xhtml+xml" = [ "com.google.Chrome.desktop" ];
      "text/html" = [ "com.google.Chrome.desktop" ];
      "x-scheme-handler/codex" = [ "codex-desktop.desktop" ];
      "x-scheme-handler/http" = [ "com.google.Chrome.desktop" ];
      "x-scheme-handler/https" = [ "com.google.Chrome.desktop" ];

      # Word documents and templates, including WPS's custom MIME types.
      "application/msword" = [ "wps-office-wps.desktop" ];
      "application/msword-template" = [ "wps-office-wps.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "wps-office-wps.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = [ "wps-office-wps.desktop" ];
      "application/vnd.ms-word.document.macroEnabled.12" = [ "wps-office-wps.desktop" ];
      "application/vnd.ms-word.template.macroEnabled.12" = [ "wps-office-wps.desktop" ];
      "application/wps-office.doc" = [ "wps-office-wps.desktop" ];
      "application/wps-office.docx" = [ "wps-office-wps.desktop" ];
      "application/wps-office.dot" = [ "wps-office-wps.desktop" ];
      "application/wps-office.dotx" = [ "wps-office-wps.desktop" ];

      # PowerPoint presentations, slideshows, and templates.
      "application/vnd.ms-powerpoint" = [ "wps-office-wpp.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = [ "wps-office-wpp.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = [ "wps-office-wpp.desktop" ];
      "application/vnd.openxmlformats-officedocument.presentationml.template" = [ "wps-office-wpp.desktop" ];
      "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = [ "wps-office-wpp.desktop" ];
      "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" = [ "wps-office-wpp.desktop" ];
      "application/vnd.ms-powerpoint.template.macroEnabled.12" = [ "wps-office-wpp.desktop" ];
      "application/wps-office.ppt" = [ "wps-office-wpp.desktop" ];
      "application/wps-office.pptx" = [ "wps-office-wpp.desktop" ];
      "application/wps-office.pot" = [ "wps-office-wpp.desktop" ];
      "application/wps-office.potx" = [ "wps-office-wpp.desktop" ];

      # Excel spreadsheets and templates.
      "application/vnd.ms-excel" = [ "wps-office-et.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "wps-office-et.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = [ "wps-office-et.desktop" ];
      "application/vnd.ms-excel.sheet.macroEnabled.12" = [ "wps-office-et.desktop" ];
      "application/vnd.ms-excel.sheet.binary.macroEnabled.12" = [ "wps-office-et.desktop" ];
      "application/vnd.ms-excel.template.macroEnabled.12" = [ "wps-office-et.desktop" ];
      "application/wps-office.xls" = [ "wps-office-et.desktop" ];
      "application/wps-office.xlsx" = [ "wps-office-et.desktop" ];
      "application/wps-office.xlt" = [ "wps-office-et.desktop" ];
      "application/wps-office.xltx" = [ "wps-office-et.desktop" ];
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
      UserMode=balanced_mode
      fan1SpeedSettings=30|30|30|30|30|30|30
      fan1TempSettings=50|55|60|65|70|75
      fan2SpeedSettings=30|30|30|30|30|30|30
      fan2TempSettings=55|60|65|70|75|80
      fanModeAdvanced=true
    '';
  };
}
