# Repository architecture

[English](architecture.md) | [简体中文](architecture.zh-CN.md) | [README](../README.md)

The repository currently exports `nixosConfigurations.Pisces`. Pisces
manages the `chomsky` account through the Home Manager NixOS module. Each new
host can declare its own accounts and choose which system and home modules to
import. A username can recur on different hosts with different permissions,
applications, and preferences.

## Configuration flow

```text
flake.nix + flake.lock
└── nixosConfigurations.Pisces
    └── hosts/Pisces/default.nix
        ├── Pisces hardware, boot, networking, and host services
        ├── Selected NixOS modules from system/
        └── hosts/Pisces/users/chomsky.nix
            ├── Unix account, group memberships, and SSH allowlist
            ├── Selected Home Manager modules from home/
            └── Pisces-specific desktop and development settings
```

| Change | Location |
| --- | --- |
| Register a host or change shared input pins | [flake.nix](../flake.nix) and [flake.lock](../flake.lock) |
| Change a host's storage, GPU, boot, networking, or service choices | [hosts/Pisces/](../hosts/Pisces) |
| Change an account's groups, login shell, autostart, Git identity, or module selection | [hosts/Pisces/users/chomsky.nix](../hosts/Pisces/users/chomsky.nix) |
| Change the avatar, wallpaper collection, or Vitis wrapper on Pisces | [hosts/Pisces/assets/](../hosts/Pisces/assets) and [hosts/Pisces/users/](../hosts/Pisces/users) |
| Change reusable system services or supported programs | [system/](../system) |
| Change reusable application settings, shells, or Niri fragments | [home/](../home) |
| Change a local package recipe | [packages/](../packages) |
| Change WebDAV mount definitions or encrypted values | [hosts/Pisces/webdav.nix](../hosts/Pisces/webdav.nix) and [secrets/webdav.yaml](../secrets/webdav.yaml) |

The host passes the DMS package, matching Quickshell package, and DMS source
to the desktop configuration. Home Manager uses the host's stable package set.
Pisces also supplies `unstablePkgs` to the Home Manager modules that select
software from the pinned unstable input. Both users and hosts use explicit
imports, so a file added to a directory takes effect when it is imported.

## Add another host

1. Create a directory under `hosts/` with a `default.nix` and a hardware
   configuration generated for that machine. Set its hostname, platform, boot
   loader, filesystems, networking, and `system.stateVersion`. The latter tracks
   the host's initial NixOS state defaults.
2. Import the services the machine needs. For a graphical host using the
   existing desktop modules, use [Pisces's host composition](../hosts/Pisces/default.nix)
   as the reference for upstream NixOS module imports and the matching DMS and
   Quickshell packages. Choose any hardware-specific settings for the new host
   from its own hardware inventory.
3. Import Home Manager on the host if it will manage user environments. Add and
   import its account files as described below.
4. Register the new output in [flake.nix](../flake.nix) using the same pattern
   as `nixosConfigurations.Pisces`. For example, a host named `Lyra` gets a
   `nixosConfigurations.Lyra` output with `modules = [ ./hosts/Lyra ];`.
5. Stage the new files, run the flake check, and build the new host output
   before activating it. Use the new output name in place of `Pisces` in the
   [validation commands](operations.md#validate-and-apply).

## Add an account to a host

1. Create `hosts/<host>/users/<username>.nix` and import it from that host's
   `default.nix`. Define `users.users.<username>` and set the shell, groups,
   and SSH access appropriate for that account.
2. Define `home-manager.users.<username>` for a managed home, choose its initial
   `home.stateVersion`, and explicitly import the modules it needs. With the
   integrated Home Manager, the Unix account supplies the username and home
   directory.
3. Add account-specific startup and application preferences in that file or
   in a file it imports. The `tty1` desktop startup on Pisces belongs to
   `chomsky`. The Niri module also seeds writable DMS fragments on first
   activation, so review the [migration behavior](desktop.md#desktop-configuration)
   when adding it to an existing home.
4. Grant WebDAV access only to the accounts that use it. Define mounts and
   secret ownership together and restore the intended machine's age identity
   separately. See [Secrets and WebDAV](operations.md#secrets-and-webdav).

## Choose the source of a change

Prefer the pinned stable Nixpkgs package or an existing NixOS or Home Manager
option. The pinned unstable input covers selected exceptions such as QQ, uv,
and the Yosys/SymbiYosys pair. Use `packages/` for local packaging work such as
integrating a vendor release or an app that needs NixOS-specific adjustments.
For a package pin or input upgrade, follow
[Update pinned inputs and packages](operations.md#update-pinned-inputs-and-packages).

The lockfile describes the inputs used to build a generation. DMS preferences,
libvirt domains and disks, Flatpak updates, credentials, and Vitis installations
have their own storage and lifecycle. See the
[operations guide](operations.md#boot-signing-and-recovery) for the scope of a
generation rollback.
