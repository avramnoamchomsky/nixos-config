{ pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      # This machine only needs hardware-accelerated guests for its host
      # architecture; qemu_kvm omits the extra cross-architecture emulators.
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
    };
  };

  # Configure virt-manager to use the system libvirt connection by default.
  programs.virt-manager.enable = true;

  users.users.chomsky.extraGroups = [ "libvirtd" ];
}
