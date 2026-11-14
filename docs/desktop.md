# Desktop guide

[English](desktop.md) | [简体中文](desktop.zh-CN.md) | [README](../README.md)

Home Manager owns the desktop files and assets described here. Apply changes
through the [system rebuild workflow](operations.md#validate-and-apply), and
acquire changed group memberships with a fresh login. Shell examples use Bash;
start `bash` from Fish before the avatar example below.

## Contents

- [Desktop configuration](#desktop-configuration)
- [Everyday shortcuts](#everyday-shortcuts)
- [Applications and system integrations](#applications-and-system-integrations)
- [Desktop themes](#desktop-themes)
- [WeChat](#wechat), [WPS Office](#wps-office), and [Ghost Downloader](#ghost-downloader)
- [Baidu Netdisk](#baidu-netdisk), [115 Life](#115-life), and [115 Browser](#115-browser)
- [Readest](#readest) and [SylvaKru](#sylvakru)
- [Steam and Bottles](#steam-and-bottles)
- [Fish and archive commands](#fish-and-archive-commands)

## Desktop configuration

The flake pins Dux Modular Shell (DMS) to the official stable release. Home
Manager installs the release's Niri configuration and sets up writable fragments
under `~/.config/niri/dms/`. DMS manages shortcuts, window rules, input devices,
cursor, displays, layout, colors, recent windows, and wallpaper integration.
Use the DMS Settings app to change them.

The first activation backs up previous DMS preferences and Niri fragments in
sibling `*-before-stock.*` directories and starts with the stock configuration.
Later rebuilds leave edits from DMS in place. The Wood Whale account avatar and
pink rose wallpaper are retained. Home Manager installs the avatar through
AccountsService and links the wallpaper collection under `~/Pictures/Wallpapers`.

UDisks and the Home Manager `udiskie` service mount eligible removable storage
under `/run/media/chomsky/`. Home Manager also creates the standard XDG user
directories and provides the `nvim.desktop` launcher for Neovim in Ghostty.

## Everyday shortcuts

Use `Mod+Shift+Slash` to open the DMS cheatsheet or `Mod+Comma` to open Settings.
On the Niri desktop, `Mod` is Super by default.

| Shortcut | Action |
| --- | --- |
| `Mod+T` or `Mod+Return` | Open Ghostty |
| `Mod+Space` | Open the application launcher |
| `Mod+D` | Toggle the dashboard |
| `Mod+V` | Toggle the clipboard manager |
| `Mod+Alt+L` | Lock the screen |
| `Mod+O` or `Mod+Tab` | Toggle the overview |
| `Alt+Tab` | Switch recent windows |
| `Mod+1` through `Mod+9` | Focus a workspace |
| `Mod+Shift+1` through `Mod+Shift+9` | Move a column to a workspace |
| `Print` / `Ctrl+Print` / `Alt+Print` | Use DMS to capture a region / screen / window |
| `Mod+Shift+P` | Turn off monitors |

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
| Proxy core | sing-box CLI installed system-wide from stable Nixpkgs; no proxy service is configured |
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
- KiCad and its editors use [WhiteSur](https://github.com/vinceliuice/WhiteSur-gtk-theme)
  (`WhiteSur-Dark`) through package wrappers in `home/programs.nix`, including
  application-menu and file-association launches. Only those launchers set
  `GTK_THEME` and add WhiteSur's data directory; the theme is not installed in
  the shared profile, and other applications keep the desktop theme above.

The generated GTK, qt5ct, qt6ct, and Kvantum files are Home Manager-owned.
Make persistent changes in `home/themes.nix`; graphical tools may be unable
to save directly to the managed files.

## WeChat

Home Manager installs the official [WeChat Linux](https://linux.weixin.qq.com/)
`4.1.13.26` x86_64 AppImage, pinned by version and SHA-256 in
`home/packages/wechat.nix`. It reuses Nixpkgs' WeChat AppImage packaging and
FHS runtime. Tencent replaces the file at its download URL when releasing an
update; update the version and hash together when upgrading.

The `wechat` launcher selects XWayland and Fcitx for Chinese input in Niri.
After applying the configuration, fully exit and reopen WeChat to use the new
version.

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

## Baidu Netdisk

Home Manager installs the [official Baidu Netdisk Linux client](https://pan.baidu.com/download),
version `8.7.0`, from the x86_64 Debian package pinned by SHA-256 in
`home/packages/baidunetdisk.nix`. The package retains the bundled Electron,
patches executable interpreters for NixOS, and supplies both GTK 2 and GTK 3
dependencies through the launcher. Bundled shared libraries remain unmodified
because the native startup integrity check exits if they change. The launcher selects XWayland and
Fcitx for Chinese input under Niri and preserves the vendor's `--no-sandbox`
launch flag.

After applying the configuration, launch **Baidu Netdisk** (**百度网盘**) from
the application menu or run `baidunetdisk`, then sign in with your Baidu account
or scan the login QR code. `home/baidunetdisk.nix` registers
`baiduyunguanjia://` links with the same packaged desktop launcher.

Account data, settings, and download history remain writable in your home
directory and outside Git. Upgrade by changing the pinned version and hash,
then rebuilding NixOS.

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
