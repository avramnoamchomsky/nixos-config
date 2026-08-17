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

  # Keep libvirt's built-in NAT network enabled across fresh installations and
  # start it when it is not already active.
  systemd.services.libvirt-default-network = {
    description = "Configure the default libvirt NAT network";
    requires = [ "libvirtd.service" ];
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      libvirt
      gnugrep
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      virsh --connect qemu:///system net-autostart default

      if ! virsh --connect qemu:///system net-list --name \
        | grep --fixed-strings --line-regexp --quiet default; then
        virsh --connect qemu:///system net-start default
      fi
    '';
  };

  users.users.chomsky.extraGroups = [ "libvirtd" ];
}
