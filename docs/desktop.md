# Desktop guide

[English](desktop.md) | [简体中文](desktop.zh-CN.md) | [README](../README.md)

Home Manager owns the desktop files and assets described here. Apply changes
through the [system rebuild workflow](operations.md#validate-and-apply), and
acquire changed group memberships with a fresh login. Shell examples use Bash;
start `bash` from Fish before the avatar example below.

## Contents

- [Declarative desktop state](#declarative-desktop-state) and [DMS avatar](#dms-avatar)
- [Everyday shortcuts](#everyday-shortcuts)
- [Applications and system integrations](#applications-and-system-integrations)
- [Desktop themes](#desktop-themes)
- [WPS Office](#wps-office), [Ghost Downloader](#ghost-downloader), [115 Life](#115-life), and [115 Browser](#115-browser)
- [Readest](#readest) and [SylvaKru](#sylvakru)
- [Steam and Bottles](#steam-and-bottles)
- [Fish and archive commands](#fish-and-archive-commands)

## Declarative desktop state

- Niri reads only `~/.config/niri/config.kdl`, deployed from
  `home/niri/config.kdl`.
- DMS-generated optional Niri fragments are unused and automatically removed.
- Reviewed DMS settings are tracked in `home/dms/settings.json`.
- The DMS avatar is declared in `home/dms.nix` using
  `home/dms/Wood_Whale.jpg`; see [DMS avatar](#dms-avatar) below.
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

The managed paths and writable state have different update rules:

| State | Source and behavior |
| --- | --- |
| Niri configuration | `home/niri/config.kdl` is deployed as a read-only Home Manager link |
| DMS settings and clipboard preferences | `home/dms/settings.json` and `home/dms.nix` produce read-only configuration files |
| DMS session | `~/.local/state/DankMaterialShell/session.json` stays writable; activation restores the declared theme/night-mode preferences and pink-rose wallpaper while preserving other fields |
| Themes, input method, MIME defaults, and MSI preferences | Edit `home/themes.nix`, `home/input-method.nix`, or `home/desktop.nix`; generated files are managed by Home Manager |
| Application data | Browser profiles, accounts, libraries, and download history remain outside Git |

An invalid existing DMS session JSON makes activation stop rather than replace
it. Inspect and back up the state file before repairing it. To persist a new
wallpaper default, change `wallpaperPath` in `home/dms.nix` and add the asset to
`home/wallpapers/`.

### DMS avatar

The original Wood Whale JPEG is tracked in `home/dms/Wood_Whale.jpg`; builds
use this repository copy and do not depend on `~/Downloads`. `home/dms.nix`
uses ImageMagick to build a PNG in the Nix store, resized to fit within
512×512 pixels while preserving the composition and removing metadata. The smaller image fits AccountsService's
1 MiB icon limit while leaving the original JPEG unchanged.

Home Manager's `dmsProfileImage` activation hook finds the configured user
through AccountsService and sets its `IconFile`. The native NixOS DMS module
enables AccountsService. When `dms.service` is running, the hook also calls
DMS's profile IPC to refresh the cached image immediately. When the shell is
stopped, it reads the account icon on its next start. Settings, the dashboard,
the control center, and the lock screen share this avatar; other applications
that read the AccountsService icon also see it.

To change the declared avatar, replace `home/dms/Wood_Whale.jpg`, or update the
`profileImage` source in `home/dms.nix`, then follow
[Validate and apply](operations.md#validate-and-apply). Add any new source
file to Git's index before evaluating the flake so Nix includes it. Changing the avatar in
the DMS settings UI is temporary: the next Home Manager activation restores
the repository's declared image.

After activation, check the account icon and the running shell as your normal
user:

```bash
account_path=$(busctl --system --json=short call \
  org.freedesktop.Accounts /org/freedesktop/Accounts \
  org.freedesktop.Accounts FindUserByName s "$USER" | jq -r '.data[0]')
busctl --system get-property org.freedesktop.Accounts "$account_path" \
  org.freedesktop.Accounts.User IconFile
dms ipc call profile getImage
```

AccountsService normally reports `/var/lib/AccountsService/icons/chomsky`,
which contains a copy of the generated PNG. The running DMS shell may report
either that path or the generated `dms-wood-whale-avatar.png` path in the Nix
store. Both should display the same image.

## Everyday shortcuts

The key names below match `home/niri/config.kdl`. Open Niri's shortcut overlay
with `Mod+Shift+Slash` for the complete binding list.

| Shortcut | Action |
| --- | --- |
| `Mod+T` | Open Ghostty |
| `Mod+D` | Toggle the DMS application launcher |
| `Super+Alt+L` | Lock the screen |
| `Mod+O` | Toggle the overview |
| `Mod+Q` | Close the focused window |
| `Mod+H/J/K/L` or `Mod+Arrow` | Focus an adjacent column/window |
| `Mod+Ctrl+H/J/K/L` or `Mod+Ctrl+Arrow` | Move the focused column/window |
| `Mod+1` through `Mod+9` | Focus a workspace |
| `Mod+Ctrl+1` through `Mod+Ctrl+9` | Move a column to a workspace |
| `Mod+F` / `Mod+Shift+F` | Maximize the column / fullscreen the window |
| `Mod+V` | Toggle floating |
| `Print` / `Ctrl+Print` / `Alt+Print` | DMS interactive / screen / window screenshot, followed by Satty |
| `Mod+Shift+P` | Turn off monitors |
| `Mod+Shift+E` or `Ctrl+Alt+Delete` | Quit Niri |

Monitor power-off leaves the system running. Volume, media, microphone-mute,
and brightness keys use DMS IPC and are also available while locked.

## Applications and system integrations

`home/programs.nix` declares most user applications and commands;
`system/desktop.nix` supplies services, device access, fonts, and capability
wrappers. The [dated software audit](software-audit-2026-10-04.md) records the
installation decisions; the Nix modules define what is installed now.

| Area | Applications or integration |
| --- | --- |
| Creative work | GIMP, Blender, Audacity, Kdenlive, OBS Studio, draw.io, Freeplane, and Zotero |
| Electronics | KiCad, FreeCAD, Serial Studio, ngspice, and PulseView; PulseView supplies libsigrok USB rules |
| Networking | LocalSend (`localsend_app`, TCP/UDP `53317`), Nmap/Zenmap, iperf3, Wireshark, Trippy (`trip`), SSHFS, FreeRDP, Remmina, and Moonlight |
| Capture permissions | Wireshark's `dumpcap` wrapper permits members of `wireshark` to capture network traffic; USB capture is disabled. Trippy uses the NixOS capability wrapper |
| Monitoring | btop with NVML and ROCm SMI, NVTOP, amdgpu_top, and HardInfo2; see [graphics diagnostics](operations.md#hybrid-graphics-and-monitoring) |
| Media CLI | FFmpeg/FFprobe, ImageMagick, GStreamer and base/good/bad/ugly/libav plugins |
| Defaults | Chrome for HTTP/HTTPS, HTML, and PDF; WPS for Microsoft Office formats; Swayimg for PNG/JPEG/GIF/WebP/BMP/TIFF/AVIF |
| Fonts | Noto/CJK/emoji, JetBrains Mono Nerd Font, Inter, LXGW WenKai, Maple Mono NF-CN, Font Awesome, Material Icons/Symbols, Terminus, and pinned Zhuque Fangsong `0.212` |

Log out and back in after changing the `wireshark` group. A package's presence
does not establish that a peripheral, remote peer, or every GPU sensor works.
Chinese TeX setup is covered in the [development guide](development.md#chinese-tex).

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
Make persistent changes in `home/themes.nix`; graphical tools may be unable
to save directly to the managed files.

## WPS Office

Home Manager installs the Chinese personal edition from the stable
`wpsoffice-cn` package, currently pinned to `12.1.2.25882`. Its Writer (`wps`),
Spreadsheets (`et`), Presentation (`wpp`), and PDF (`wpspdf`) launchers explicitly
select XWayland and Fcitx for Chinese input in Niri. Application-menu entries
use the same wrappers. Chinese text uses the system's existing Noto CJK fonts.

WPS is the default application for Microsoft Word, PowerPoint, and Excel files,
including templates and macro-enabled document formats. The defaults cover
both standard MIME types and WPS's custom MIME types. Google Chrome remains the
default browser and opens PDF files by default.

Launch WPS from the application menu or with `wps` after applying the configuration.

## Ghost Downloader

Home Manager installs [Ghost Downloader v4.3.7](https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/tag/v4.3.7)
from the official x86_64 AppImage, pinned by SHA-256 in
`home/packages/ghost-downloader.nix`. The package supplies an FHS environment
for the bundled Python and Qt libraries, plus FFmpeg for media downloads.

Launch `ghost-downloader` from the shell or **Ghost Downloader** from the
application menu. `home/ghost-downloader.nix` registers the
`ghostdownloader://` URI handler with the Nix wrapper, so browser links launch
the same working executable.

Application settings, download history, and feature packs remain writable in
`~/.local/share/GhostDownloader/`. On a fresh installation, TLS certificate
verification is enabled and application update checks are disabled. Update
the application by changing the pinned version and checksum, then rebuilding
NixOS; later rebuilds preserve settings changed inside the application.

For browser download interception, install the optional
[Ghost Downloader for Browser extension](https://chromewebstore.google.com/detail/ghost-downloader-for-brow/lagbjgkmaafnlinaeonbhjchnjinjpeh)
and pair it through Ghost Downloader's setup wizard or browser-integration
settings. The desktop application works independently of the extension.

## 115 Life

The [official 115 Life 37.3.1 Linux release](https://115.com/115/T984564.html)
is pinned by version and SHA-256 in `home/packages/115-life.nix` and installed
through `home/115-life.nix`. The package keeps the bundled .NET runtime and
ICU libraries, patches native binaries for NixOS, and supplies Avalonia's X11
libraries, WebKitGTK 4.1, secret storage, notifications, and media dependencies.
Under Niri, the desktop client uses XWayland.

Launch **115生活** from the application menu or run `115-life` (`115life` also
works), then sign in with your 115 account or scan the login QR code. The
`life115://` handler uses the same Nix wrapper. Torrent files offer the app
through **Open With**; their default association remains a user preference.

Settings and account data remain writable in your home directory. Update the
pinned package version and hash, then rebuild NixOS to upgrade the application.

## 115 Browser

The [official x86_64 Linux release](https://q.115.com/115/T888199.html) of 115
Browser is packaged declaratively in `home/packages/115-browser.nix`. Version
`35.30.0` and its download hash are pinned, the vendor binary is adapted to
NixOS, and it is forced through XWayland because its Transfer Manager renders
incorrectly on native Wayland under Niri. Launch it as `115-browser` or from
the application launcher.

The vendor build reports Chromium `125.0.6422.61`, which is old. Use it only for
115-specific functionality; Google Chrome remains the default browser for
general browsing.

The browser cannot update files inside the immutable Nix store. Updating it
requires changing the version, official URL, and hash in the package definition
and rebuilding the system.

## Readest

[Readest](https://github.com/readest/readest) is built as a native Nix package
from the pinned `0.12.10` upstream release in `home/packages/readest.nix`,
using the `nixpkgs-unstable` package set for its dependencies. This avoids the upstream
AppImage's Wayland library-compatibility issue. Launch it as `readest` or from
the application launcher. The package disables automatic update checks and
telemetry by default. Update the package version and hashes to upgrade it.

## SylvaKru

[SylvaKru](https://github.com/AfalpHy/sylvakru) is installed from its pinned
official x86_64 Linux release in `home/packages/sylvakru.nix`. The vendor
bundle is adapted to NixOS with GTK, system-tray, secret-storage, OpenGL, and
mpv runtime libraries. It supports local music and self-hosted libraries via
WebDAV, Navidrome, and Emby. Launch it as `sylvakru` or from the application
launcher.

The package is currently pinned to version `3.6.0`. Updating it requires
changing the version, official release URL, and hash in the package definition.

## Steam and Bottles

`system/gaming.nix` enables Steam, protontricks, Proton GE, GameMode, gamescope,
and Steam hardware rules. The normal boot makes NVIDIA available through
`nvidia-offload`; the VFIO boot reserves it for a guest instead.

[Bottles](https://usebottles.com/) is installed as its upstream-supported
Flatpak through the pinned `nix-flatpak` flake input. Flathub and the
`com.usebottles.bottles` application are declared in `system/desktop.nix`, and
a weekly timer keeps managed Flatpaks updated. Unused Flatpak runtimes are
removed automatically. The Flathub remote uses USTC's mainland-China cache;
the management service also reconciles an existing remote to that URL before
installing or updating packages.

Flatpak applications are convergently managed rather than stored in Nix
generations, so a NixOS rollback does not roll Bottles back. Bottles remains
sandboxed; grant individual game directories through the file portal instead
of exposing the entire home directory. Its per-bottle graphics settings can
select the discrete NVIDIA GPU when a game needs it.

## Fish and archive commands

The maintained upstream 7-Zip CLI is also installed. Use either `7zz` or the
provided compatibility command `7z`; both invoke the same package from the
pinned Nixpkgs input. Fish provides `7zip` and `7sec` aliases for maximum
LZMA2 compression, plus `7zipv` and `7secv` variants that split archives into
100 GiB volumes. The `7sec` variants encrypt file contents and names with the
configured convenience passphrase.

The archive aliases are defined in `home/programs.nix`. The `7sec` variants
use a fixed passphrase in that source file; choose an explicit private password
when an archive needs confidential protection.
