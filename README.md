# NixOS Configuration

My personal declarative NixOS configuration.

This repository contains the configuration for my NixOS system, including my desktop environment, hardware configuration, hybrid graphics setup, input method, and system packages.

## System

- NixOS with flakes
- niri
- AMD + NVIDIA hybrid graphics
- Fcitx5 + Rime Ice
- Fish
- PipeWire
- NetworkManager

## Structure

```text
.
├── flake.nix
├── flake.lock
├── configuration.nix
├── hardware-configuration.nix
├── hybrid-graphics.nix
├── msi-control.nix
├── .gitignore
└── README.md