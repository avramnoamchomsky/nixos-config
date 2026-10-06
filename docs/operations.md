# Operations guide

[English](operations.md) | [简体中文](operations.zh-CN.md) | [README](../README.md)

These procedures target `pisces` and `chomsky`. Run Nix commands from the
repository root. Shell examples use Bash; commands without Bash-specific syntax
also work in the configured Fish shell.

## Contents

- [Validate and apply](#validate-and-apply)
- [Update pinned inputs and packages](#update-pinned-inputs-and-packages)
- [Boot signing and recovery](#boot-signing-and-recovery)
- [Hybrid graphics and monitoring](#hybrid-graphics-and-monitoring)
- [Power management](#power-management)
- [MSI controls and trackpad](#msi-controls-and-trackpad)
- [Secrets and WebDAV](#secrets-and-webdav)
- [Networking and host services](#networking-and-host-services)
- [Virtual machines](#virtual-machines) and [RTX 4060 passthrough](#rtx-4060-passthrough)

## Validate and apply

Home Manager is integrated into `nixosConfigurations.pisces`. A system rebuild
also builds and activates the `chomsky` environment. `system.stateVersion` and
`home.stateVersion` are compatibility settings, both `26.05`; changing them is
not an input-update procedure.

1. Review the working tree with `git status --short` and `git diff`. Add new Nix
   source files and assets to Git's index so the Git flake can see them.
2. Evaluate the flake without updating its lockfile:

   ```bash
   nix flake check --no-build --no-update-lock-file
   ```

3. Build the complete system without activating it:

   ```bash
   nix build --no-link --no-update-lock-file .#nixosConfigurations.pisces.config.system.build.toplevel
   ```

   For a focused Home Manager check, build its activation package instead:

   ```bash
   nix build --no-link --no-update-lock-file .#nixosConfigurations.pisces.config.home-manager.users.chomsky.home.activationPackage
   ```

The flake check evaluates outputs; it does not compile packages or run the
activation hooks. A successful build confirms the requested output can be
realized, while service, hardware, and application behavior still require
checks after activation. `--no-link` avoids creating a local `result` symlink.

Choose activation according to the change and the current boot mode:

| Situation | Apply with | Effect |
| --- | --- | --- |
| Ordinary package, desktop, or service change in normal mode | `sudo nixos-rebuild switch --flake .#pisces` | Install a generation and activate the normal system and Home Manager immediately |
| Kernel, initrd, GPU-driver, VFIO, or boot-loader change | `sudo nixos-rebuild boot --flake .#pisces` | Install the next boot generation; use it after reboot |
| Currently booted into VFIO | `sudo nixos-rebuild boot --flake .#pisces` | Keep the running GPU ownership until a controlled reboot |

Shut down guests before rebooting, then run `sudo reboot`. A normal `switch`
while VFIO or a guest owns the RTX 4060 may try to return the device to NVIDIA.
Both workflows build the inherited `vfio` specialisation; parent changes apply
to both modes except for the overrides in `system/vfio.nix`.

After a switch, check the relevant services, for example:

```bash
systemctl status home-manager-chomsky.service
systemctl --user status dms.service
journalctl -b -u home-manager-chomsky.service
```

Log out and back in, or reboot, after changes to `docker`, `libvirtd`,
`wireshark`, `dialout`, or `plugdev` membership. A successful rebuild alone
does not update the groups of an existing desktop session.

## Update pinned inputs and packages

`flake.lock` fixes the input revisions. Stable Nixpkgs and Home Manager follow
their 26.05 branches; selected applications use `nixpkgs-unstable` through
`unstablePkgs`. Updating that input does not move the whole system to unstable.
Other inputs provide nix-flatpak, sops-nix, Lanzaboote, and the
`codex-desktop-linux` desktop integration.

Update a specific input as the normal user, review the lockfile diff, then
validate and rebuild. For example:

```bash
nix flake update codex-desktop-linux
git diff -- flake.lock
```

The same command with `nixpkgs-unstable` updates the selected unstable packages.
The driver version and hashes in `system/hybrid-graphics.nix`, the custom
application definitions in `home/packages/`, and the theme revisions in
`home/themes.nix` are additional pins. Update their versions, source URLs or
revisions, and all affected hashes when upgrading them. Readest has separate
source, Cargo, frontend, and plugin dependency hashes. Rebuilds alone preserve
these pins.

Bottles follows the declared Flatpak weekly updater, and Ubuntu packages inside
the Vitis container follow apt. Those updates are separate from Nix generations.

## Boot signing and recovery

`system/default.nix` uses Lanzaboote `v1.1.0` to install systemd-boot with unified
kernel images. Signing keys are generated locally under `/var/lib/sbctl`;
`allowUnsigned = true` allows the initial rebuild before keys are available.
The `fwupd-efi` service waits for `generate-sb-keys.service`.

This configuration generates signing keys but does not enroll them into firmware
or enable Secure Boot. Check firmware state separately before relying on boot
signature enforcement. Keep the local keys backed up outside Git.

systemd-boot retains up to ten configured generations. If a new generation
fails, select an older retained generation at boot. This recovers its NixOS
configuration; it does not revert Git, application data, Flatpak updates,
container packages, or virtual-machine disks.

Automatic Nix garbage collection runs weekly with `--delete-older-than 7d`.
Old profile generations can therefore be removed by garbage collection; the
ten-entry boot limit is not a guarantee of ten indefinitely recoverable systems.
Nix also optimizes the store automatically. Cache preference is SJTUG, USTC,
then the official NixOS cache.

## Hybrid graphics and monitoring

The firmware should use Hybrid/MSHybrid graphics mode. Normal boot configures
AMD Raphael graphics at `05:00.0` for the internal panel and PRIME render
offload to the RTX 4060 at `01:00.0`. NVIDIA's open kernel modules, modesetting,
Dynamic Boost, and fine-grained power management are enabled. The driver is
explicitly pinned to `610.57.04`; the kernel comes from `linuxPackages_latest`
in the locked stable input.

Run a GPU-heavy application through the host offload wrapper:

```bash
nvidia-offload vulkaninfo
nvidia-smi
```

The `amdgpu.dcdebugmask=0x40000` parameter changes the custom backlight mapping
for the recorded brightness problem near 97–98%. The VFIO boot uses the AMD
host driver and reserves the NVIDIA graphics/audio functions for a guest.

btop is built with NVIDIA NVML and AMD ROCm SMI support. Its ROCm dependency
uses the packaged PCI database so the iGPU is named Raphael. NVTOP uses NVML
headers without pulling the entire CUDA toolkit. In btop, `5` and `6` toggle
the individual GPU panels.

If readings fail in normal mode, inspect the driver and kernel logs:

```bash
nvidia-smi --query-gpu=name,gpu_recovery_action,temperature.gpu,utilization.gpu,clocks.gr --format=csv
journalctl -b -k --grep='NVRM|Xid'
btop
nvtop
```

The [2026-10-05 audit follow-up](software-audit-2026-10-04.md#gpu-monitoring-follow-up--2026-10-05)
recorded an NVIDIA reset requirement after Xid 119/GSP RPC timeout. That report
is historical and does not establish the GPU's current state. When the driver
reports a reset requirement, save work, shut down guests, and restart before
checking again. The recorded fallback is a full shutdown and power-on if a
restart does not recover it. A live reset can interrupt the desktop when Niri
holds GPU handles. Some AMD sensor fields are unsupported even when discovery
works. NVIDIA host telemetry is unavailable when the device belongs to VFIO.

## Power management

`system/power-management.nix` disables suspend, hibernation, hybrid sleep, and
suspend-then-hibernate through systemd. Hibernation is no longer planned, and
the recorded AMD platform-resume failures remain unresolved. Lid-close handling
is set to `ignore`, and DMS omits suspend and hibernate actions.

Normal memory pressure uses zram only. The former 72 GiB
`/var/lib/swapfile` is no longer configured and can be deleted after it is
deactivated. NixOS will not recreate it from this configuration.

The systemd-based initrd remains enabled. After applying the configuration,
verify the swap and disabled sleep policy with:

```bash
swapon --show
systemd-analyze cat-config systemd/sleep.conf | grep '^Allow'
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager CanSuspend
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager CanHibernate
```

Only `/dev/zram0` should appear in `swapon --show`. All four `Allow*` settings
should be `false`, and both bus calls should return `s "no"`.

The tracked DMS settings also set automatic lock and suspend timeouts to zero.
Use `Super+Alt+L` to lock manually; turning off monitors is separate from system
sleep.

## MSI controls and trackpad

`system/msi-control.nix` loads `msi-ec` and `ec_sys` for MControlCenter. This
machine's EC `17KKIMS1.115` uses the tested `17KKIMS1.114` driver layout, and
`ec_sys` write support permits custom fan curves. `home/desktop.nix` declares
balanced mode and the two fan curves; window geometry is left out of Git.
Reapply persistent hardware preferences through that module.

`system/default.nix` loads `hid_multitouch` before `hid_magicmouse` for the
external trackpad identifying as `05ac:0265`. Its second HID interface needs
multitouch support. These settings are specific to this laptop and peripheral.

## Secrets and WebDAV

`secrets/webdav.yaml` contains encrypted WebDAV usernames and passwords.
`.sops.yaml` declares the public age recipient. `system/secrets.nix` expects
the private identity outside the repository at:

```text
/home/chomsky/all_files/secrets/sops-nix/age-key.txt
```

Restore that identity before activating this system on a fresh installation.
Keep it readable only by its owner and backed up outside Git. Do not put a
private identity or decrypted credentials into a Nix expression or commit.
Edit the encrypted file from the repository root with:

```bash
SOPS_AGE_KEY_FILE=/home/chomsky/all_files/secrets/sops-nix/age-key.txt nix shell --inputs-from . --no-update-lock-file nixpkgs#sops -c sops secrets/webdav.yaml
```

`--inputs-from .` selects sops from this flake's locked Nixpkgs input. sops-nix
decrypts four secrets under `/run/secrets/rclone/`, owned by `chomsky` with mode
`0400`. Home Manager injects the secret values into rclone's configuration
without transforming them. When replacing a password, store the output of
`rclone obscure` in the encrypted YAML password field; usernames use their
ordinary values. Keep both encrypted with sops.

`home/rclone.nix` configures these mounts:

| Remote | WebDAV endpoint | Mount point |
| --- | --- | --- |
| `infini-cloud-kurio` | `https://kurio.infini-cloud.net/dav/` | `~/mnt/infini-cloud-kurio` |
| `infini-cloud-higa` | `https://higa.teracloud.jp/dav/` | `~/mnt/infini-cloud-higa` |

Both mounts use a full VFS cache under `~/.cache/rclone/<remote>`, with a
`10Gi` cache-size target, 24-hour maximum age, five-second write-back delay,
five-minute directory cache, and polling disabled. The `077` umask restricts
access to the user. A local write may still be waiting for remote upload;
inspect mount logs before stopping a mount with pending writes.

Check the user configuration service and the two mount services:

```bash
systemctl --user status rclone-config.service
systemctl --user status 'rclone-mount:@infini-cloud-kurio.service'
systemctl --user status 'rclone-mount:@infini-cloud-higa.service'
journalctl --user -b -u 'rclone-mount:@infini-cloud-kurio.service'
```

The age identity and remote accounts are required for activation and working
mounts; they are not supplied by a clone of this repository.

## Networking and host services

NetworkManager manages the host connections. Avahi advertises `pisces.local`,
publishes the workstation/address records, and resolves IPv4 `.local` names.
Bluetooth, UPower, fwupd, fstrim, PipeWire, the GNOME keyring, GVfs, and UDisks
are enabled. The Home Manager udiskie service provides removable-drive
automounting in Niri.

OpenSSH accepts `chomsky` with password authentication enabled; root login and
keyboard-interactive authentication are disabled. Its firewall opening is
managed declaratively. LocalSend opens TCP/UDP `53317`; Avahi opens its service
ports. Docker is the system daemon, with access granted through the `docker`
group.

The dedicated `enp3s0` FPGA link is trusted by the firewall and uses a static,
route-less network. Keep it attached to the intended isolated board network.
The [FPGA network guide](development.md#fpga-network-and-tftp) documents its
address, read-only TFTP service, and checks. Vitis VNC listens only on loopback.

## Virtual machines

`system/virtualization.nix` enables libvirt with the hardware-accelerated
`qemu_kvm` package and configures virt-manager to connect to
`qemu:///system`. QEMU guests run as the unprivileged `qemu-libvirtd` account,
and software TPM support is available for guests that require TPM 2.0. UEFI
firmware is included by the pinned QEMU package.

The built-in `default` NAT network is marked for autostart and started when
necessary by `libvirt-default-network.service`; manual `virsh net-start` and
`virsh net-autostart` commands are not required.

After applying the configuration, log out and back in (or reboot) so the
`chomsky` account receives its new `libvirtd` group membership. Then launch
`virt-manager` from the application launcher or a terminal. New virtual disks
managed by libvirt are stored under `/var/lib/libvirt/images/`. When selecting
an ISO from the home directory, allow virt-manager to grant the
`qemu-libvirtd` account the required directory access if prompted.

Because the storage pool resides on Btrfs, its directory declaratively inherits
the NOCOW (`C`) attribute. This avoids stacking Btrfs copy-on-write beneath
qcow2 copy-on-write for newly created virtual disks. Existing disk files are
not converted, and NOCOW files do not use Btrfs data checksumming or
compression.

To verify hardware acceleration and the system connection:

```bash
test -e /dev/kvm && echo "KVM is available"
virsh --connect qemu:///system list --all
lsattr -d /var/lib/libvirt/images
```

The `lsattr` output should contain an uppercase `C`. The command is installed
system-wide by the `e2fsprogs` package.

`virtiofsd` is registered with libvirt for sharing host directories with
guests. With the guest shut down, enable shared memory on virt-manager's
**Memory** screen, then use **Add Hardware > Filesystem** with the `virtiofs`
driver, a host source directory, and an arbitrary target tag. The unprivileged
`qemu-libvirtd` account must be able to traverse and access the entire source
path; use a dedicated shared directory or a targeted ACL instead of opening the
whole home directory. Linux guests mount the tag with
`mount -t virtiofs TAG MOUNTPOINT`; Windows guests require WinFsp and the
VirtIO-FS guest components from the virtio-win media.

Remmina is installed as the graphical RDP client for the Windows 11 guest.
Enable Remote Desktop inside Windows, obtain the guest address with
`virsh --connect qemu:///system net-dhcp-leases default`, then create an RDP connection in Remmina for
that address. The Windows account must have a password and permission to use
Remote Desktop.

The existing hardware configuration loads `kvm-amd`, while its `nested=0`
module option prevents guests such as Taurus from running nested virtual
machines. Keep CPU virtualization (SVM) enabled in the firmware settings;
the NixOS host still requires it to provide `/dev/kvm`. Verify the host setting
with `cat /sys/module/kvm_amd/parameters/nested`; it should print `0`.

### RTX 4060 passthrough

`system/vfio.nix` adds a `vfio` specialisation without changing the normal boot
configuration. The normal entry keeps the RTX 4060 available to NixOS through
PRIME offload. The `vfio` entry binds the two NVIDIA functions to `vfio-pci`
during the initrd:

```text
01:00.0  NVIDIA RTX 4060                 10de:28a0
01:00.1  NVIDIA High Definition Audio    10de:22be
```

Install both boot entries without switching the running system into VFIO mode:

```bash
sudo nixos-rebuild boot --flake .#pisces
```

After rebooting into the `vfio` specialisation, verify that both functions show
`Kernel driver in use: vfio-pci`:

```bash
lspci -nnk -s 01:00.0
lspci -nnk -s 01:00.1
```

Check the current IOMMU groups before assigning devices. The previous machine
setup recorded group 13, but firmware or hardware changes can alter grouping.
Taurus is the existing Windows guest; its domain, disks, and PCI assignments
are local libvirt state and are not created by this flake.

With Taurus fully shut down, open its hardware details in virt-manager and use
**Add Hardware > PCI Host Device** to add both NVIDIA functions. Keep the
VirtIO video and SPICE devices as a recovery console. Windows retains its
NVIDIA driver when the physical devices are later removed from the VM.

Before using Taurus in the normal boot mode, shut it down and remove only the
two NVIDIA PCI host devices in virt-manager. They can also be removed after
booting normally, provided Taurus has not been started. Taurus then uses its
existing VirtIO/SPICE display while NixOS retains the RTX 4060. Do not remove
the separately passed-through `05:00.3` USB controller.

The internal laptop panel remains attached to the AMD iGPU in both modes.
Physical NVIDIA HDMI/DisplayPort outputs belong to Windows in VFIO mode; RDP
can be used when no external display is connected.
