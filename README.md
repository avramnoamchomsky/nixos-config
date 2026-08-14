# NixOS Configuration

[English](README.md) | [简体中文](README.zh-CN.md)

Declarative configuration for the `pisces` laptop and the `chomsky` user environment.

## Highlights

- NixOS flakes with Home Manager integrated into the system rebuild
- Niri with a complete Git-owned KDL configuration
- Dank Material Shell with reviewed settings and declarative wallpapers
- AMD + NVIDIA hybrid graphics
- Fcitx5 with Rime Ice
- PipeWire, NetworkManager, Bluetooth, and Avahi/mDNS
- Fish and desktop applications, including Google Chrome as the default browser
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
│   └── secrets.nix
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

## Declarative desktop state

- Niri reads only `~/.config/niri/config.kdl`, deployed from
  `home/niri/config.kdl`.
- DMS-generated optional Niri fragments are unused and automatically removed.
- Reviewed DMS settings are tracked in `home/dms/settings.json`.
- Selected DMS session preferences are merged declaratively while histories,
  detected devices, and other volatile state remain writable.
- Wallpapers in `home/wallpapers/` are deployed to `~/Pictures/Wallpapers`.
  DMS derives its wallpaper cycling directory from the selected wallpaper path.

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
- GTK 4/libadwaita is intentionally left on its native appearance. Applying a
  third-party GTK 4 theme requires a CSS workaround that can break application
  styling.

The generated GTK, qt5ct, qt6ct, and Kvantum files are Home Manager-owned.
Changes made in the graphical tools are temporary and should be copied back to
`home/themes.nix` if they are meant to persist.

## Embedded development

- `esp32-shell` opens the flake-based ESP32 environment from
  `~/all_files/projects/dev-envs/esp32`.
- `~/all_files/projects/esp32/.envrc` automatically loads the same environment
  through direnv and nix-direnv.
- STM32 tools include STM32CubeMX, the Arm embedded toolchain, CMake, Ninja,
  OpenOCD, and ST-Link utilities.
- Membership in `dialout` and `plugdev`, plus the OpenOCD and ST-Link udev
  rules, grants access to supported development boards after a fresh login.

## Validate and apply

Evaluate the complete flake without building:

```bash
nix flake check --no-build
```

Apply the complete NixOS and Home Manager configuration:

```bash
sudo nixos-rebuild switch --flake .#pisces
```

## Before committing

1. Review the diff and ensure no plaintext secrets are present.
2. Run checks appropriate to the change, normally at least
   `nix flake check --no-build`.
3. Update this README first when architecture, paths, services, workflows, or
   documented behavior have changed.
4. Commit only after the documentation and implementation agree.
