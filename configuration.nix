{ config, pkgs, unstablePkgs, ... }:

let
  wechat-fcitx = pkgs.symlinkJoin {
    name = "wechat-fcitx";

    paths = [
      pkgs.wechat
    ];

    nativeBuildInputs = [
      pkgs.makeWrapper
    ];

    postBuild = ''
      wrapProgram $out/bin/wechat \
        --set XMODIFIERS "@im=fcitx" \
        --set QT_IM_MODULE "fcitx" \
        --set GTK_IM_MODULE "fcitx" \
        --set QT_QPA_PLATFORM "xcb"
    '';
  };
in

{
  imports = [
    ./hardware-configuration.nix
    ./hybrid-graphics.nix
    ./msi-control.nix
  ];


  # ============================================================
  # Identity / locale
  # ============================================================

  networking.hostName = "pisces";

  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";

  # ============================================================
  # Input method: Fcitx5 + Rime Ice + 小鹤双拼
  # ============================================================

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      waylandFrontend = true;

      addons = with pkgs; [
        (fcitx5-rime.override {
          rimeDataPkgs = [
            rime-ice
          ];
        })
      ];
    };
  };

  console.keyMap = "us";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };


  # ============================================================
  # Boot
  # ============================================================

  boot.loader.systemd-boot = {
    enable = true;

    # Keep several older NixOS generations available.
    configurationLimit = 10;

    # Prevent arbitrary kernel command-line editing from the
    # systemd-boot menu.
    editor = false;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # Follow the latest kernel series available in our pinned
  # NixOS 26.05 nixpkgs revision.
  boot.kernelPackages = pkgs.linuxPackages_latest;


  # ============================================================
  # Swap
  # ============================================================

  # RAM-backed compressed swap.
  #
  # Do not create a large disk swap partition during installation
  # unless we later decide to configure hibernation.
  zramSwap.enable = true;


  # ============================================================
  # Firmware
  # ============================================================

  # Includes redistributable firmware such as linux-firmware.
  # Useful for Wi-Fi, Bluetooth, AMD GPU firmware, etc.
  hardware.enableRedistributableFirmware = true;


  # ============================================================
  # Nix
  # ============================================================

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;

    # Mainland-China mirrors first, official cache last.
    substituters = [
      "https://mirrors.sjtug.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];

    connect-timeout = 10;
    stalled-download-timeout = 30;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Required for Google Chrome and NVIDIA.
  nixpkgs.config.allowUnfree = true;


  # ============================================================
  # User
  # ============================================================

  users.users.chomsky = {
    isNormalUser = true;

    description = "chomsky";

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    shell = pkgs.fish;
  };


  # ============================================================
  # SSH
  # ============================================================

  # Keep password SSH enabled during initial hardware setup.
  #
  # After the laptop is fully configured, switch this to
  # public-key authentication only.
  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";

      AllowUsers = [
        "chomsky"
      ];
    };
  };


  # ============================================================
  # Networking
  # ============================================================

  networking.networkmanager.enable = true;


  # ============================================================
  # Bluetooth
  # ============================================================

  hardware.bluetooth.enable = true;


  # ============================================================
  # Laptop power / battery information
  # ============================================================

  services.upower.enable = true;


  # ============================================================
  # Audio
  # ============================================================

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  programs.nix-ld.enable = true;


  # ============================================================
  # Niri
  # ============================================================

  programs.niri = {
    enable = true;

    # Uses Nautilus as the xdg-desktop-portal-gnome
    # FileChooser implementation.
    useNautilus = true;
  };


  # ============================================================
  # DankMaterialShell
  # ============================================================

  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    # Useful on the physical laptop.
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableClipboardPaste = true;

    # Keep these optional features disabled initially.
    enableAudioWavelength = false;
    enableCalendarEvents = false;
  };


  # ============================================================
  # DankGreeter
  # ============================================================

  services.displayManager.dms-greeter = {
    enable = true;

    compositor = {
      name = "niri";

      customConfig = ''
        input {
            keyboard {
                xkb {
                    layout "us"
                }
            }
        }

        cursor {
            xcursor-theme "Adwaita"
            xcursor-size 24
        }
      '';
    };
  };


  # ============================================================
  # Desktop infrastructure
  # ============================================================

  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  # Unlock the login keyring through PAM.
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  programs.dconf.enable = true;

  # Nautilus / removable-media infrastructure.
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Bottles will be installed through Flatpak.
  services.flatpak.enable = true;


  # ============================================================
  # Fish
  # ============================================================

  programs.fish.enable = true;

  environment.localBinInPath = true;


  # ============================================================
  # Neovim
  # ============================================================

  programs.neovim = {
    enable = true;

    defaultEditor = true;

    viAlias = true;
    vimAlias = true;
  };

  # ============================================================
  # ChatGPT Desktop
  # ============================================================

  programs.codexDesktopLinux = {
    enable = true;

  # Ensure the graphical launcher always knows exactly where
  # the Codex CLI is, even when launched from DMS.
    cliPackage = unstablePkgs.codex;
  };


  # ============================================================
  # Wayland / cursor
  # ============================================================

  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";

    # Prefer native Wayland for Chromium/Electron applications.
    NIXOS_OZONE_WL = "1";
  };


  # ============================================================
  # SSD maintenance / firmware updating
  # ============================================================

  services.fstrim.enable = true;

  services.fwupd.enable = true;


  # ============================================================
  # Packages
  # ============================================================

  environment.systemPackages = with pkgs; [

    # ----------------------------------------------------------
    # GUI
    # ----------------------------------------------------------

    google-chrome
    nautilus
    mpv
    vscode
    gh

    # Chinese input configuration
    qt6Packages.fcitx5-configtool

    # Messaging
    unstablePkgs.qq
    wechat-fcitx


    # ----------------------------------------------------------
    # Terminal
    # ----------------------------------------------------------

    ghostty
    unstablePkgs.codex

    nodejs


    # ----------------------------------------------------------
    # Wayland / X11 compatibility
    # ----------------------------------------------------------

    # Niri 25.08+ automatically detects and starts
    # xwayland-satellite on demand when it is in PATH.
    xwayland-satellite

    wl-clipboard


    # ----------------------------------------------------------
    # Appearance
    # ----------------------------------------------------------

    adwaita-icon-theme


    # ----------------------------------------------------------
    # CLI
    # ----------------------------------------------------------

    git
    curl
    wget
    rsync
    openssh

    eza
    bat
    ripgrep
    fd
    fzf
    zoxide
    jq

    tealdeer
    fastfetch


    # ----------------------------------------------------------
    # TUI
    # ----------------------------------------------------------

    yazi
    lazygit
    btop


    # ----------------------------------------------------------
    # Storage / encryption diagnostics
    # ----------------------------------------------------------

    cryptsetup
    btrfs-progs
    nvme-cli
    smartmontools


    # ----------------------------------------------------------
    # Hardware / boot diagnostics
    # ----------------------------------------------------------

    pciutils
    usbutils
    efibootmgr


    # ----------------------------------------------------------
    # Graphics diagnostics
    # ----------------------------------------------------------

    vulkan-tools
    mesa-demos
  ];


  # ============================================================
  # Fonts
  # ============================================================

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji

    nerd-fonts.jetbrains-mono
  ];


  # ============================================================
  # NixOS compatibility
  # ============================================================

  system.stateVersion = "26.05";
}
