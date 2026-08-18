{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./desktop.nix
    ./hybrid-graphics.nix
    ./msi-control.nix
    ./power-management.nix
    ./secrets.nix
    ./virtualization.nix
  ];

  # Identity and locale
  networking.hostName = "pisces";
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  # Boot
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep following the newest kernel in the pinned stable release.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  users.users.chomsky = {
    isNormalUser = true;
    description = "chomsky";
    extraGroups = [
      "wheel"
      "networkmanager"
      "plugdev"
      "dialout"
    ];
    shell = pkgs.fish;
  };

  # Password authentication remains enabled until a replacement SSH key is set up.
  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "chomsky" ];
    };
  };

  networking.networkmanager.enable = true;

  # Local hostname and service discovery. This advertises pisces.local and
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
