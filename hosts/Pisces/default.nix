{ inputs, lib, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  # Keep DMS and Quickshell on the same Qt package set.
  desktopShell = {
    package = inputs.dms.packages.${system}.default;
    quickshell = inputs.dms.inputs.nixpkgs.legacyPackages.${system}.quickshell;
    source = inputs.dms.outPath;
  };

  unstablePkgs = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    inputs.dms.nixosModules.default
    inputs.codex-desktop-linux.nixosModules.default
    inputs.msime.nixosModules.default
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.sops-nix.nixosModules.sops
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ../../system/desktop.nix
    ../../system/embedded-linux.nix
    ./fpga.nix
    ../../system/gaming.nix
    ./hybrid-graphics.nix
    ./msi-control.nix
    ./power-management.nix
    ./vfio.nix
    ./virtualization.nix
    ./users/chomsky.nix
  ];

  _module.args = { inherit desktopShell; };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit desktopShell unstablePkgs; };
  };

  programs.msime.package = (pkgs.extend inputs.msime.overlays.default).msime-fcitx5.overrideAttrs {
    # The candidate canvas tests need fonts inside the build sandbox.
    FONTCONFIG_FILE = pkgs.makeFontsConf {
      fontDirectories = [ pkgs.dejavu_fonts pkgs.noto-fonts-cjk-sans ];
    };
    CTEST_OUTPUT_ON_FAILURE = "1";
  };

  # Identity and locale
  networking.hostName = "Pisces";
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  # Boot
  boot.loader.systemd-boot = {
    # Lanzaboote replaces the stock installer while retaining systemd-boot as
    # the boot manager and producing one UKI per retained generation.
    enable = lib.mkForce false;
    configurationLimit = 10;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;

    # Generate signing keys locally, but do not enroll them or enable Secure
    # Boot. Unsigned artifacts remain allowed for the first rebuild, before
    # the key-generation service has run.
    pkiBundle = "/var/lib/sbctl";
    allowUnsigned = true;
    autoGenerateKeys.enable = true;
  };

  # Lanzaboote signs fwupd's EFI helper whenever fwupd is enabled. On the first
  # activation, ensure the signing keys exist before that service starts.
  systemd.services.fwupd-efi = {
    requires = [ "generate-sb-keys.service" ];
    after = [ "generate-sb-keys.service" ];
  };

  # Keep following the newest kernel in the pinned stable release.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # This external trackpad uses Apple's USB ID 05ac:0265, but its second HID
  # interface needs hid-multitouch. If magicmouse loads first, it claims both
  # interfaces and the trackpad stops reporting movement and gestures.
  boot.extraModprobeConfig = ''
    softdep hid_magicmouse pre: hid_multitouch
  '';

  hardware.enableRedistributableFirmware = true;

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
    options = "--delete-older-than 7d";
  };

  # Required for applications such as Google Chrome and the NVIDIA driver.
  nixpkgs.config.allowUnfree = true;

  users.groups.plugdev = { };

  # Password authentication remains enabled until a replacement SSH key is set up.
  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.networkmanager.enable = true;

  # Local hostname and service discovery. This advertises Pisces.local and
  # allows resolving other IPv4 .local hosts on the LAN.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;

    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.udev.packages = [
    pkgs.openocd
    pkgs.stlink
  ];
  hardware.bluetooth.enable = true;
  services.upower.enable = true;

  programs.nix-ld.enable = true;

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  system.stateVersion = "26.05";
}
