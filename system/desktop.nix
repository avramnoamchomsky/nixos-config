{ pkgs, unstablePkgs, ... }:

let
  rpiImagerPolicy = pkgs.writeText "com.raspberrypi.rpi-imager.policy.in" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE policyconfig PUBLIC
      "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
      "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
    <policyconfig>
      <vendor>Raspberry Pi Ltd</vendor>
      <vendor_url>https://www.raspberrypi.com/</vendor_url>
      <action id="com.raspberrypi.rpi-imager">
        <description>Run Raspberry Pi Imager with elevated privileges</description>
        <message>Authentication is required to write a Raspberry Pi image</message>
        <defaults>
          <allow_any>no</allow_any>
          <allow_inactive>no</allow_inactive>
          <allow_active>auth_admin_keep</allow_active>
        </defaults>
        <annotate key="org.freedesktop.policykit.exec.path">@rpi-imager@</annotate>
      </action>
    </policyconfig>
  '';

  rpiImager = pkgs.symlinkJoin {
    name = "rpi-imager-with-polkit-${pkgs.rpi-imager.version}";
    paths = [ pkgs.rpi-imager ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram "$out/bin/rpi-imager" \
        --run "if [[ \"\$EUID\" -ne 0 ]]; then exec /run/wrappers/bin/pkexec \"$out/bin/rpi-imager\" \"\$@\"; fi"

      install -Dm644 ${rpiImagerPolicy} \
        "$out/share/polkit-1/actions/com.raspberrypi.rpi-imager.policy"
      substituteInPlace \
        "$out/share/polkit-1/actions/com.raspberrypi.rpi-imager.policy" \
        --replace-fail "@rpi-imager@" "$out/bin/rpi-imager"
    '';

    meta = pkgs.rpi-imager.meta;
  };
in
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
        location = "https://mirrors.ustc.edu.cn/flathub";
      }
    ];

    packages = [ "com.usebottles.bottles" ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    uninstallUnused = true;
  };

  # nix-flatpak adds missing remotes but does not reconcile the URL of an
  # existing one. Keep the system Flathub remote on the reachable USTC cache.
  systemd.services.flatpak-managed-install.preStart = ''
    if ${pkgs.flatpak}/bin/flatpak remotes --system --columns=name \
      | ${pkgs.gnugrep}/bin/grep -qx flathub; then
      ${pkgs.flatpak}/bin/flatpak remote-modify --system flathub \
        --url=https://mirrors.ustc.edu.cn/flathub
    fi
  '';

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
    rpiImager
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
