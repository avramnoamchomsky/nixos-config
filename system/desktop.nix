{ pkgs, unstablePkgs, ... }:

{
  # Input method: Fcitx5 + Rime Ice + Xiaohe Shuangpin.
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [ rime-ice ];
        })
      ];
    };
  };

  console.keyMap = "us";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableClipboardPaste = true;
    enableAudioWavelength = false;
    enableCalendarEvents = false;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
      user = "greeter";
    };
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  programs.dconf.enable = true;

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [ "com.usebottles.bottles" ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    uninstallUnused = true;
  };

  # Fish must be registered system-wide before it can be a login shell.
  programs.fish.enable = true;

  programs.codexDesktopLinux = {
    enable = true;
    cliPackage = unstablePkgs.codex;
  };

  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    AWT_TOOLKIT = "MToolkit";
  };

  environment.systemPackages = with pkgs; [
    # Desktop infrastructure
    nautilus
    qt6Packages.fcitx5-configtool
    xwayland-satellite
    adwaita-icon-theme

    # Hardware access and administration
    stlink
    cryptsetup
    btrfs-progs
    nvme-cli
    smartmontools
    pciutils
    usbutils
    efibootmgr
    vulkan-tools
    mesa-demos
  ];

  # STM32 / ST-Link USB access.
  services.udev.packages = [ pkgs.stlink ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];
}
