# NixOS Configuration

Declarative configuration for the `pisces` laptop and the `chomsky` user environment.

## System

- NixOS with flakes
- niri
- AMD + NVIDIA hybrid graphics
- Fcitx5 + Rime Ice
- Home Manager, integrated into the NixOS rebuild
- Fish
- PipeWire
- NetworkManager

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
│   └── msi-control.nix
├── home
│   ├── default.nix
│   ├── desktop.nix
│   ├── dms.nix
│   ├── input-method.nix
│   ├── niri.nix
│   ├── niri
│   │   └── config.kdl
│   └── programs.nix
├── .gitignore
└── README.md
```

`system/` contains machine-wide configuration: hardware, boot, services,
security, desktop infrastructure, and administrative tools.

`home/` contains the applications, command-line environment, and configuration
owned by the `chomsky` account.

Niri and the reviewed DMS preferences are Git-owned. DMS runtime data such as
history, device pins, and detected displays remains mutable and is not tracked.

## Apply

```bash
sudo nixos-rebuild switch --flake .#pisces
```
