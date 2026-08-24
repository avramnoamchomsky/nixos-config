# NixOS Configuration

[English](README.md) | [简体中文](README.zh-CN.md)

Declarative configuration for the `pisces` laptop and the `chomsky` user environment.

## Highlights

- NixOS flakes with Home Manager integrated into the system rebuild
- `linuxPackages_latest`, currently pinned to Linux `7.1.8`
- Niri with a complete Git-owned KDL configuration
- Dank Material Shell with reviewed settings and declarative wallpapers
- AMD + NVIDIA hybrid graphics with a boot-selectable RTX 4060 VFIO mode
- System sleep disabled pending AMD platform-resume fixes
- Fcitx5 with Rime Ice
- PipeWire, NetworkManager, Bluetooth, and Avahi/mDNS
- KVM/QEMU virtualization managed by libvirt and virt-manager
- Automatic removable-drive mounting through UDisks and udiskie
- Fish and desktop applications, including Remmina, SylvaKru, Readest, 115 Browser, and Google Chrome as the default browser
- Declarative MacTahoe GTK and Kvantum themes with nwg-look, qt5ct, and qt6ct
- ESP32 and STM32 development tooling with direnv and hardware access rules
- sops-nix encrypted secrets backed by a machine-local age identity
- Automatic rclone WebDAV mounts for two InfiniCLOUD accounts and the optional LAN host `aquarius.local`

## Structure

```text
.
├── flake.nix
├── flake.lock
├── system
│   ├── default.nix
│   ├── desktop.nix
│   ├── hardware-configuration.nix
│   ├── hybrid-graphics.nix
│   ├── msi-control.nix
│   ├── power-management.nix
│   ├── secrets.nix
│   ├── vfio.nix
│   └── virtualization.nix
├── home
│   ├── default.nix
│   ├── desktop.nix
│   ├── dms.nix
│   ├── dms
│   │   └── settings.json
│   ├── input-method.nix
│   ├── niri.nix
│   ├── niri
│   │   └── config.kdl
│   ├── packages
│   │   ├── 115-browser.nix
│   │   └── sylvakru.nix
│   ├── programs.nix
│   ├── rclone.nix
│   ├── themes.nix
│   └── wallpapers
│       └── ...
├── secrets
│   └── webdav.yaml
├── .sops.yaml
├── .gitignore
├── README.md
└── README.zh-CN.md
```

`system/` contains machine-wide hardware, boot, networking, services, security,
and secret-decryption configuration. `home/` contains the applications and user
configuration owned by the `chomsky` account.

## Suspend and hibernation

`system/power-management.nix` disables s2idle, S4, hybrid sleep, and
suspend-then-hibernate while the current AMD platform-resume failures remain
unfixed. Lid-close handling is set to `ignore`, and DMS does not expose
suspend or hibernate actions, preventing accidental entry into a broken state.

Normal memory pressure continues to use zram. Hibernation instead uses the
72 GiB `/var/lib/swapfile`, which NixOS creates with the Btrfs-compatible NOCOW
attributes. The file resides inside the LUKS-encrypted root filesystem, so the
saved memory image is encrypted at rest.

The systemd-based initrd retains the infrastructure needed to discover the
swap file and its Btrfs offset dynamically if S4 is re-enabled later. Keeping
the swap file active does not enable hibernation. After applying the
configuration and rebooting, verify the disabled policy with:

```bash
swapon --show
systemd-analyze cat-config systemd/sleep.conf | grep '^Allow'
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager CanSuspend
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager CanHibernate
```

All four `Allow*` settings should be `false`, and both bus calls should return
`s "no"`. If `/var/lib/swapfile` is removed, the next rebuild recreates it.

## Declarative desktop state

- Niri reads only `~/.config/niri/config.kdl`, deployed from
  `home/niri/config.kdl`.
- DMS-generated optional Niri fragments are unused and automatically removed.
- Reviewed DMS settings are tracked in `home/dms/settings.json`.
- Selected DMS session preferences are merged declaratively while histories,
  detected devices, and other volatile state remain writable.
- Wallpapers in `home/wallpapers/` are deployed to `~/Pictures/Wallpapers`.
  DMS derives its wallpaper cycling directory from the selected wallpaper path.
- UDisks handles removable storage at the system level, while the Home Manager
  `udiskie` service automatically mounts eligible filesystems under
  `/run/media/chomsky/`. Partitions marked by UDisks as ignored remain unmounted.
- Home Manager declares the standard XDG user directories and creates missing
  folders such as `Documents`, `Downloads`, `Music`, and `Pictures`. This also
  supplies the paths expected by Flutter desktop applications such as SylvaKru.
- The `nvim.desktop` entry launches Neovim explicitly inside Ghostty. This
  keeps Nautilus file associations working without relying on GLib to discover
  a terminal emulator in the minimal Niri session.

## WebDAV mounts and secrets

The WebDAV usernames and passwords in `secrets/webdav.yaml` are encrypted with
sops-nix. The private age identity is stored outside Git at:

```text
/home/chomsky/all_files/secrets/sops-nix/age-key.txt
```

The configured mount points are:

```text
~/mnt/infini-cloud-kurio
~/mnt/infini-cloud-higa
~/mnt/aquarius
```

`aquarius.local` is allowed to be offline. Its user service retries failed
startup every 30 seconds without blocking boot. It currently uses plain HTTP,
so HTTPS should be preferred if the server gains support for it.

## Desktop themes

- GTK 2/3 uses `MacTahoe-Dark-nord`, selectable and inspectable with
  `nwg-look`.
- Qt 5/6 uses `qt5ct`/`qt6ct` as the platform configuration layer and the
  `MacTahoeDark` Kvantum theme. `kvantummanager` remains available for
  inspection.
- Both themes are built from pinned revisions of the official
  [MacTahoe GTK](https://github.com/vinceliuice/MacTahoe-gtk-theme) and
  [MacTahoe KDE](https://github.com/vinceliuice/MacTahoe-kde) repositories.
- GTK 4/libadwaita uses the same theme through Home Manager's explicit CSS
  import workaround. GTK 4 does not officially support third-party themes, so
  some applications may still have visual inconsistencies.

The generated GTK, qt5ct, qt6ct, and Kvantum files are Home Manager-owned.
Changes made in the graphical tools are temporary and should be copied back to
`home/themes.nix` if they are meant to persist.

## 115 Browser

The [official x86_64 Linux release](https://q.115.com/115/T888199.html) of 115
Browser is packaged declaratively in `home/packages/115-browser.nix`. Version
`35.30.0` and its download hash are pinned, the vendor binary is adapted to
NixOS, and Wayland input-method support is enabled when running under Niri.
Launch it as `115-browser` or from the application launcher.

The vendor build reports Chromium `125.0.6422.61`, which is old. Use it only for
115-specific functionality; Google Chrome remains the default browser for
general browsing.

The browser cannot update files inside the immutable Nix store. Updating it
requires changing the version, official URL, and hash in the package definition
and rebuilding the system.

## Readest

[Readest](https://github.com/readest/readest) is installed from the
`nixpkgs-unstable` package set for a newer native Nix build that avoids the
upstream AppImage's Wayland library-compatibility issue. Launch it as `readest`
or from the application launcher. Its version advances when the flake's
unstable input is updated.

## SylvaKru

[SylvaKru](https://github.com/AfalpHy/sylvakru) is installed from its pinned
official x86_64 Linux release in `home/packages/sylvakru.nix`. The vendor
bundle is adapted to NixOS with GTK, system-tray, secret-storage, OpenGL, and
mpv runtime libraries. It supports local music and self-hosted libraries via
WebDAV, Navidrome, and Emby. Launch it as `sylvakru` or from the application
launcher.

The package is currently pinned to version `3.6.0`. Updating it requires
changing the version, official release URL, and hash in the package definition.

## Embedded development

- `esp32-shell` opens the flake-based ESP32 environment from
  `~/all_files/projects/dev-envs/esp32`.
- `~/all_files/projects/esp32/.envrc` automatically loads the same environment
  through direnv and nix-direnv.
- STM32 tools include STM32CubeMX, the Arm embedded toolchain, CMake, Ninja,
  OpenOCD, and ST-Link utilities.
- Membership in `dialout` and `plugdev`, plus the OpenOCD and ST-Link udev
  rules, grants access to supported development boards after a fresh login.

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
`virsh net-dhcp-leases default`, then create an RDP connection in Remmina for
that address. The Windows account must have a password and permission to use
Remote Desktop.

The existing hardware configuration loads `kvm-amd`, and its `nested=1` module
option explicitly enables nested virtualization for host-passthrough guests
such as Taurus. Keep CPU virtualization (SVM) enabled in the firmware settings;
`/dev/kvm` will be unavailable if SVM is disabled. Verify the host setting with
`cat /sys/module/kvm_amd/parameters/nested`; it should print `1`.

### RTX 4060 passthrough

`system/vfio.nix` adds a `vfio` specialisation without changing the normal boot
configuration. The normal entry keeps the RTX 4060 available to NixOS through
PRIME offload. The `vfio` entry binds both isolated members of IOMMU group 13
to `vfio-pci` during the initrd:

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

## Validate and apply

NixOS does not monitor these files automatically. After every configuration
change, first evaluate the complete flake without building:

```bash
nix flake check --no-build
```

For ordinary package, desktop, and service changes made while running the
normal boot mode, apply the complete NixOS and Home Manager configuration:

```bash
sudo nixos-rebuild switch --flake .#pisces
```

`switch` creates a new boot generation, activates the normal configuration
immediately, and rebuilds its inherited `vfio` specialisation. Changes to the
parent configuration normally appear in both modes; `system/vfio.nix`
overrides only the settings needed to reserve the RTX 4060.

For kernel, initrd, VFIO, GPU-driver, or boot-loader changes, install the new
generation without changing the running system and then reboot:

```bash
sudo nixos-rebuild boot --flake .#pisces
sudo reboot
```

Prefer `boot` whenever the system is currently running in VFIO mode. Shut down
Taurus before rebooting; a normal `switch` could otherwise try to return the
RTX 4060 to the NVIDIA driver while the guest or VFIO still owns it.

Each successful rebuild creates a generation, and systemd-boot retains up to
the ten generations configured by `boot.loader.systemd-boot.configurationLimit`.
Select an older generation at boot to recover from a broken change. Git and
system activation remain separate: committing does not rebuild the machine,
and rebuilding does not commit the configuration.

## Before committing

1. Review the diff and ensure no plaintext secrets are present.
2. Run checks appropriate to the change, normally at least
   `nix flake check --no-build`.
3. Update this README first when architecture, paths, services, workflows, or
   documented behavior have changed.
4. Commit only after the documentation and implementation agree.
