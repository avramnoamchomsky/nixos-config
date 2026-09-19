{ config, ... }:

{
  # ============================================================
  # AMD iGPU + NVIDIA RTX 4060 Laptop GPU
  #
  # Intended mode:
  #
  #   AMD iGPU
  #     -> Niri / desktop / normal applications
  #
  #   NVIDIA RTX 4060
  #     -> render offload for games / GPU-heavy applications
  #
  # BIOS should be in Hybrid / MSHybrid mode.
  # ============================================================


  # Generic Mesa / graphics stack.
  hardware.graphics.enable = true;

  # Diagnose the malformed brightness response around 97-98%.
  # DC_DISABLE_CUSTOM_BRIGHTNESS_CURVE keeps the standard backlight mapping.
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x40000" ];

  # This activates the NixOS NVIDIA driver module.
  #
  # The PRIME module itself configures the AMD side when
  # amdgpuBusId is supplied.
  services.xserver.videoDrivers = [
    "nvidia"
  ];


  hardware.nvidia = {

    # Required/recommended for modern Wayland use.
    modesetting.enable = true;

    # RTX 4060 is an Ada GPU; use NVIDIA's open kernel modules.
    open = true;

    # Starts nvidia-powerd. MControlCenter uses this for NVIDIA
    # Dynamic Boost when changing performance profiles.
    dynamicBoost.enable = true;

    # NixOS 26.05 still packages 595.71.05, which does not build
    # against Linux 7.2. Pin the newer NVIDIA branch explicitly.
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "610.57.04";
      sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
      sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
      openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
      settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
      persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
    };


    # ----------------------------------------------------------
    # Laptop power management
    # ----------------------------------------------------------

    powerManagement = {
      enable = true;

      # Allows runtime D3 power management while using
      # PRIME offload.
      finegrained = true;
    };


    # ----------------------------------------------------------
    # PRIME render offload
    # ----------------------------------------------------------

    prime = {

      # From this laptop's lspci output:
      #
      #   05:00.0 AMD Raphael integrated graphics
      #   01:00.0 NVIDIA RTX 4060 Laptop GPU
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";


      offload = {
        enable = true;

        # Creates:
        #
        #   nvidia-offload <program>
        #
        # Example:
        #
        #   nvidia-offload vulkaninfo
        #
        enableOffloadCmd = true;
      };
    };
  };
}
