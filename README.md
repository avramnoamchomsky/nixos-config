# NixOS Configuration

Declarative configuration for the `pisces` laptop and the `chomsky` user environment.

## Highlights

- NixOS flakes with Home Manager integrated into the system rebuild
- Niri with a complete Git-owned KDL configuration
- Dank Material Shell with reviewed settings and declarative wallpapers
- AMD + NVIDIA hybrid graphics
- Fcitx5 with Rime Ice
- PipeWire, NetworkManager, Bluetooth, and Avahi/mDNS
- Fish and desktop applications, including Google Chrome as the default browser
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
│   └── wallpapers
│       └── ...
├── secrets
│   └── webdav.yaml
├── .sops.yaml
├── .gitignore
└── README.md
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
