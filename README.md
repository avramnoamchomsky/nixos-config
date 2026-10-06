# Pisces NixOS configuration

[English](README.md) | [简体中文](README.zh-CN.md)

Personal NixOS configuration for the `pisces` MSI Alpha 17 C7VF laptop and the
`chomsky` account. One flake rebuild manages the system and its Home Manager
configuration. Hardware identifiers, filesystem UUIDs, user paths, and external
development environments are specific to this machine.

## Configuration at a glance

| Area | Configuration |
| --- | --- |
| Platform | `x86_64-linux`; NixOS and Home Manager 26.05; timezone `Asia/Shanghai` |
| Package sources | Stable Nixpkgs for the system, with selected applications from a separate pinned unstable input |
| Kernel and graphics | `linuxPackages_latest`; evaluated lockfile selects Linux `7.2.6`; NVIDIA driver `610.57.04` is pinned explicitly |
| Desktop | greetd/tuigreet → Niri with Dank Material Shell (DMS), Ghostty, Nautilus, and XWayland |
| Input and audio | Fcitx5, Rime Ice with Xiaohe Shuangpin, and PipeWire/WirePlumber |
| Appearance | Declarative MacTahoe GTK/Kvantum themes, Wood Whale avatar, and wallpaper collection |
| Storage | LUKS-encrypted Btrfs, zram, automatic removable-drive mounting, and two rclone WebDAV mounts |
| Virtualization | libvirt/KVM, virt-manager, Docker/Distrobox, and an RTX 4060 `vfio` boot specialisation |
| Development | ESP32/STM32, HDL/formal tools, and Ubuntu 22.04 Vitis/Vivado 2023.2 |
| Applications | Chrome, WPS Office, Ghost Downloader, 115 Life/Browser, Readest, SylvaKru, creative tools, Steam, and Flatpak Bottles |

The versions above describe the evaluated repository pins as of 2026-10-06.
They do not identify the generation currently running on the laptop.

**Suspend and hibernation are disabled. Closing the lid does not suspend the
machine.** The AMD platform-resume problems recorded for this laptop remain
unresolved; see [power management](docs/operations.md#power-management).

## Validate and apply

Run these commands from the repository root on the configured machine. NixOS
needs Nix commands and flakes enabled. Before first activation, restore the
machine-local age identity described in [secrets and WebDAV](docs/operations.md#secrets-and-webdav).

```bash
cd ~/all_files/projects/nixos-config
nix flake check --no-build --no-update-lock-file
nix build --no-link --no-update-lock-file .#nixosConfigurations.pisces.config.system.build.toplevel
```

For ordinary desktop, package, or service changes while booted normally, apply
the system and Home Manager together:

```bash
sudo nixos-rebuild switch --flake .#pisces
```

For kernel, initrd, GPU-driver, VFIO, or boot-loader changes, use
`sudo nixos-rebuild boot --flake .#pisces` and reboot after shutting down guests.
Use the same `boot` workflow while running the VFIO specialisation. The
[operations guide](docs/operations.md#validate-and-apply) explains validation,
activation, input updates, and recovery.

Committing files does not activate them. NixOS does not automatically rebuild
when a file changes. Add new source files to Git before evaluating a local Git
flake so Nix includes them.

## Documentation

| Guide | Contents |
| --- | --- |
| [Operations](docs/operations.md) / [运维](docs/operations.zh-CN.md) | Build and activation, boot signing, hybrid graphics, power policy, secrets, networking, virtual machines, and VFIO |
| [Desktop](docs/desktop.md) / [桌面](docs/desktop.zh-CN.md) | Configuration ownership, shortcuts, avatar, themes, applications, MIME defaults, capture permissions, and gaming |
| [Development](docs/development.md) / [开发](docs/development.zh-CN.md) | Embedded and HDL tools, FPGA TFTP network, Vitis/Vivado installation and VNC, Android tools, imaging, and Chinese TeX |
| [Software audit — 2026-10-04](docs/software-audit-2026-10-04.md) | Historical inventory, installation decisions, recorded checks, and the 2026-10-05 GPU-monitoring follow-up |

The guides describe the current declarations. The dated audit records the
observations made during that installation batch; its generation numbers,
local application state, sensor readings, and disk-space figures are historical.

## Repository map

| Path | Responsibility |
| --- | --- |
| [flake.nix](flake.nix), [flake.lock](flake.lock) | Inputs, reproducible pins, `pisces` output, and Home Manager integration |
| [system/default.nix](system/default.nix), [system/hardware-configuration.nix](system/hardware-configuration.nix) | Module imports, identity, boot, Nix settings, networking, user, and local storage |
| [system/desktop.nix](system/desktop.nix), [system/gaming.nix](system/gaming.nix) | Session, input, audio, desktop services, permissions, fonts, Flatpak, and Steam |
| [system/hybrid-graphics.nix](system/hybrid-graphics.nix), [system/vfio.nix](system/vfio.nix) | NVIDIA driver, PRIME offload, and GPU-reservation specialisation |
| [system/power-management.nix](system/power-management.nix), [system/msi-control.nix](system/msi-control.nix) | Sleep policy, zram, and MSI embedded-controller support |
| [system/virtualization.nix](system/virtualization.nix), [system/fpga.nix](system/fpga.nix) | KVM/libvirt, Docker, programmer access, and FPGA network/TFTP service |
| [system/secrets.nix](system/secrets.nix), [.sops.yaml](.sops.yaml), [secrets/webdav.yaml](secrets/webdav.yaml) | Encrypted WebDAV credentials and their decryption policy |
| [home/default.nix](home/default.nix), [home/programs.nix](home/programs.nix) | User modules, XDG directories, packages, Fish, CLI tools, and development environments |
| [home/desktop.nix](home/desktop.nix), [home/input-method.nix](home/input-method.nix) | MIME associations, desktop preferences, MControlCenter, and Fcitx/Rime state |
| [home/niri.nix](home/niri.nix), [home/niri/config.kdl](home/niri/config.kdl) | Complete Niri configuration and cleanup of unused DMS fragments |
| [home/dms.nix](home/dms.nix), [home/dms/settings.json](home/dms/settings.json), [home/dms/Wood_Whale.jpg](home/dms/Wood_Whale.jpg) | DMS settings, merged session preferences, wallpaper default, and generated avatar |
| [home/themes.nix](home/themes.nix), [home/wallpapers](home/wallpapers) | Pinned themes and tracked wallpaper assets |
| [home/ghost-downloader.nix](home/ghost-downloader.nix), [home/115-life.nix](home/115-life.nix), [home/packages](home/packages) | Custom application packages, launchers, URI handlers, and Zhuque Fangsong |
| [home/rclone.nix](home/rclone.nix), [home/vitis.nix](home/vitis.nix) | User mounts and AMD-tool/container wrappers and VNC service |

## Contributing changes

Edit the source module or asset, validate the relevant output, and update both
language versions of the affected guide. Review `git diff --check` and the full
diff before committing; keep decrypted credentials, private keys, application
history, and generated build files outside Git. Configuration changes normally
require at least the flake check above and a build of the affected output.
Documentation-only changes need link, command, and consistency checks.

The repository configuration is available under the [MIT license](LICENSE).
Packaged applications and third-party assets retain their respective licenses.
