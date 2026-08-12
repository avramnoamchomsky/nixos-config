{ ... }:

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

  # Diagnose partial-screen flicker on the internal panel at 240 Hz.
  # Force amdgpu to use full-frame updates instead of damage clips.
  boot.kernelParams = [ "amdgpu.damageclips=0" ];

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

    # Use the highest stable NVIDIA branch from our pinned
    # kernel package set.
    branch = "stable";


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
