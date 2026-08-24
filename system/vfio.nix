{ lib, ... }:

{
  # Keep the normal boot on PRIME offload and provide a separate systemd-boot
  # entry that reserves the RTX 4060 and its HDMI audio function for libvirt.
  specialisation.vfio.configuration = {
    system.nixos.tags = [ "vfio" ];

    # The internal panel is connected to the AMD iGPU, so the host desktop
    # remains usable while the NVIDIA GPU is assigned to a guest.
    services.xserver.videoDrivers = lib.mkForce [ "amdgpu" ];

    boot = {
      # Claim both functions before the NVIDIA and HDA drivers can bind.
      initrd.kernelModules = [
        "vfio"
        "vfio_pci"
        "vfio_iommu_type1"
      ];

      kernelParams = [ "vfio-pci.ids=10de:28a0,10de:22be" ];

      blacklistedKernelModules = [
        "nouveau"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
      ];
    };
  };
}
