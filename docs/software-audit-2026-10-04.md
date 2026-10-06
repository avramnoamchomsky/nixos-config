# Software audit — 2026-10-04

Source: the local browser export `bookmarks_10_4_26.html` (2,622 bookmarks, 2,617 unique URLs). Bookmark contents were treated as data, not instructions. This report does not copy account links, browser history, or credentials.

## Implementation status

The approved installation batch was built and activated successfully as NixOS generation **112**. Home Manager completed with exit status 0. The approved applications, commands, fonts, and system integrations are installed using the existing flake pins. No application removals were made. Ventoy and the editor/desktop integration batch remain deferred. See the October 5 follow-up below for the GPU-monitoring correction and outstanding NVIDIA recovery.

Original installation system: `/nix/store/r56v548cxjs5k9p261h0aiw2mdqri09y-nixos-system-pisces-26.05.20260918.cf9d2fb`.

## How to read the inventory

- **Installed before / Retained:** found in the existing profile/configuration or a named environment. Retain these packages.
- **Added by this change:** selected by the user, installed, and activated by this change.
- **Private dependency → exposed CLI:** previously present under another program or service; now also explicitly placed on the user's PATH.
- **Private/system dependency:** required runtime/library support; not automatically a missing user command.
- **Skipped:** user declined the addition.
- **Deferred:** optional software or integrations without approval in this batch. Absence from the normal profile does not prove absence from every custom directory; /opt was not accessible during the audit.
- **Project scope / Project environment / Project/server scope / Other platform / Service website:** requires a project, guest/device, server setup, or account rather than automatic workstation installation.

The 279 software folders are all listed below, together with extensions, fonts, proprietary tools, service websites, and container candidates. Library/documentation, OS-image, hardware, and archived-resource bookmarks are not treated as install requests.

## Integration and permissions

| Integration | Configuration |
| --- | --- |
| PulseView | NixOS program module installs libsigrok device rules and firmware dependencies. |
| LocalSend | NixOS program module opens TCP/UDP 53317. |
| Wireshark | Full GUI/CLI package; dumpcap wrapper allows members of wireshark to capture network traffic; chomsky joins that group. USB capture remains disabled. A fresh login acquires the new group. |
| Trippy | NixOS provides the trip wrapper with raw-packet capability. |
| Screenshots | Existing Print/Ctrl+Print/Alt+Print actions use DMS; its user service runs Satty with the captured path. |
| Images | PNG/JPEG/GIF/WebP/BMP/TIFF/AVIF default to swayimg.desktop. |
| Media CLI | FFmpeg headless, ImageMagick, GStreamer and base/good/bad/ugly/libav plugins are on the normal user profile. |
| TeX | Medium scheme with LuaTeX, XeTeX, bibliography tools, and Chinese collections. |
| Fonts | Added as choices; existing default-font configuration is unchanged. Google bookmark maps to material-icons/material-symbols, not the unrelated community material-design-icons package. |
| Zhuque Fangsong | Official beta v0.212 ZIP; SHA-256 SRI: sha256-u4tmGnZD0ilqctnRBTCgCUlBnE5Sf7YXg/c8K6GowGI=. |

## Cleanup assessment

| Installed software | Evidence / decision |
| --- | --- |
| Bottles | Default bottle directory was empty; user explicitly chose to retain it. |
| KDiskMark | Optional disk benchmark; user explicitly chose to retain it. |
| wlr-randr | No persistent configuration reference found, but its query works; user explicitly chose to retain it. |
| Remmina | Existing profiles and a running applet support retaining it. |
| Readest / SylvaKru | Existing library/settings data support retaining them. |
| Steam / OBS | Existing game entries or application configuration; no removal approved. |
| OpenCodex | Local installation and active proxy service; retain. |
| SDKs and transitive dependencies | Keep project-specific environments and required closures. Duplicate runtime versions can serve different pinned packages. |

No application removal is justified with sufficient confidence, and none is included. Existing automatic Nix/Flatpak cleanup policies are unchanged.

## Deferred decisions

The VS Code/Yazi/mpv/Nautilus integration batch is deferred, including the eleven proposed VS Code extensions, Yazi chmod/git/mount plugins, ModernZ, and open-in-Ghostty. Other bookmarked plugin/theme additions are also unselected. All eleven bookmarked Chrome extensions and both bookmarked VS Code Catppuccin themes already exist.

Ventoy is deferred because the pinned Nixpkgs package is marked insecure for unverifiable upstream binary blobs; there is no permittedInsecurePackages exception. See the [Nixpkgs issue](https://github.com/NixOS/nixpkgs/issues/404663). Java/Rust/Ruby toolchains, LLDB, Unsloth, USB/IP, eSIM/NFC utilities, proxy servers, printing services, and additional themes require a specific workflow before installation.

## Bookmark inventory

### containers / authentication

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| openlist api token generator | Project/server scope | No container stack or database service added in this batch. |

### containers / cloud storage

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| openlist | Project/server scope | No container stack or database service added in this batch. |

### containers / content creation

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| bentopdf | Project/server scope | No container stack or database service added in this batch. |
| mermaid live editor | Project/server scope | No container stack or database service added in this batch. |

### containers / data

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| mariadb | Project/server scope | No container stack or database service added in this batch. |
| mongodb | Project/server scope | No container stack or database service added in this batch. |
| mysql | Project/server scope | No container stack or database service added in this batch. |
| postgresql | Project/server scope | No container stack or database service added in this batch. |
| sqlite | Private/system dependency | Dependency is present; standalone sqlite3 CLI is deferred. |

### containers / digital distribution

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| jellyfin | Project/server scope | No container stack or database service added in this batch. |

### containers / remote access

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| one-kvm | Project/server scope | No container stack or database service added in this batch. |

### containers / visualization

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| teleplot | Project/server scope | No container stack or database service added in this batch. |

### containers / web

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| nginx | Project/server scope | No container stack or database service added in this batch. |

### extensions / bash plugins

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| bash-completion | Existing shell support | Fish completions are configured; a separate Bash completion setup is not selected. |

### extensions / google chrome extensions

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| allow right-click | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| bookmarks organizer | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| dark reader | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| doqment | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| gemini voyager | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| global speed | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| read frog | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| ruffle | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| steamdb | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| ubo lite | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |
| youtube auto hd | Installed before | All eleven bookmarked Chrome extensions were found in Profile 1. |

### extensions / kicad plugins

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| catppuccin for kicad eda | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |

### extensions / mpv user scripts

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| modernz | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |

### extensions / nautilus plugins

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| nautilus admin | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| nautilus copy path/name | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| nautilus-code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| nautilus-open-any-terminal | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |

### extensions / root modules

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| play integrity fix | Other platform | Android device/root module; no host installation. |
| sing-box | Deferred | Android/Windows clients and proxy core are different products; no proxy service selected. |
| teesimulator-rs | Other platform | Android device/root module; no host installation. |

### extensions / vs code extensions

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| bash language server | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| c/c++ for visual studio code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| catppuccin for vscode | Installed before | Existing VS Code theme. |
| catppuccin icons for vscode/vscodium | Installed before | Existing VS Code icon theme. |
| cmake tools | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| cortex debug | Skipped | Keep existing VS Code extensions; user explicitly declined Cortex Debug. |
| error lens | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| hdl support for vs code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| kdl for visual studio code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| linkerscript language support for vscode | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| mermaid chart extension for visual studio code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| nord visual studio code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| python extension for visual studio code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| qt extension for vs code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| ruff extension for visual studio code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| shell-format | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| shellcheck for visual studio code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| spelling checker for visual studio code | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| surfer | Installed before | The bookmark points to the standalone Surfer tool/docs, already installed. |
| yaml language support by red hat | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |

### extensions / yazi plugins

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| chmod.yazi | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| full-border.yazi | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| git.yazi | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| mount.yazi | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |
| zoom.yazi | Deferred | Editor/desktop integration batch deferred; no plugin or theme installed. |

### programs / ai environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| llama.cpp | Skipped | User declined this addition; preserve the decision. |
| opencodex | Installed before | Local npm installation and active user proxy service; retain. |
| unsloth | Project scope | Use a project environment when needed; no permanent host toolchain added. |

### programs / android modding environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| android debug bridge | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| android sdk platform-tools | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| apatch | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| apk extractor | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| fastboot | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| payload-dumper-go | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| play integrity api checker | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |

### programs / boot environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| archinstall | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| armbian imager | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| das u-boot | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| efibootmgr | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gnu grub | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| lanzaboote | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| raspberry pi imager | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| tianocore edk ii | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| ventoy | Deferred | Nixpkgs marks version 1.1.12 insecure; user chose to defer. No exception. |

### programs / compatibility layer environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| bottles | Retained | User explicitly chose to keep it; Flatpak-managed. |
| dxvk | Installed before | Managed by the existing Steam/Proton/Bottles environments. |
| ge-proton | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| proton | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| vkd3d-proton | Installed before | Managed by the existing Steam/Proton/Bottles environments. |
| waydroid | Skipped | User declined this addition; preserve the decision. |
| waydroid helper | Skipped | User declined this addition; preserve the decision. |
| windows subsystem for linux | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| wine | Installed before | Available through compatibility environments; no separate system Wine added. |

### programs / content creation environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| audacity | Added by this change | audacity |
| blender | Added by this change | blender |
| diagrams.net | Added by this change | drawio |
| ffmpeg | Private dependency → exposed CLI | ffmpeg-headless |
| freeplane | Added by this change | freeplane |
| gimp | Added by this change | gimp |
| gstreamer | Added by this change | gst_all_1.gstreamer + base/good/bad/ugly/libav |
| inkscape | Skipped | User declined this addition; preserve the decision. |
| kdenlive | Added by this change | kdePackages.kdenlive |
| krita | Skipped | User declined this addition; preserve the decision. |
| luatex | Added by this change | TeX Live collection-luatex |
| obs studio | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| tex live | Added by this change | scheme-medium + LuaTeX/XeTeX/bibliography/Chinese |

### programs / core console environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| 7-zip | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| acl | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| advanced linux sound architecture | Private/system dependency | ALSA libraries/configuration and PipeWire ALSA support exist; aplay/alsamixer are not exposed. |
| aic8800d80 | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| ansible | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| atftp | Private dependency → exposed CLI | atftp (client; server already configured) |
| avahi | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| bind | Private/system dependency | The host command is installed; the DNS server and dig are not added. |
| bluez | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| brightnessctl | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| btrfs-progs | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| busybox | Private/system dependency | Present transitively; no standalone shell command selected. |
| clinfo | Added by this change | clinfo |
| cliphist | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| cronie | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| cups | Private/system dependency | Libraries/runtime dependencies exist; printing service is not enabled. |
| curl | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| desired state configuration | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| diffutils | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| dmidecode | Private dependency → exposed CLI | dmidecode |
| dnsmasq | Private/system dependency | Existing virtualization dependency; no general DNS/DHCP server is added. |
| dosfstools | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| dtc | Added by this change | dtc |
| dynamic kernel module support | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| e2fsprogs | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| exfatprogs | Added by this change | exfatprogs |
| fail2ban | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| fd | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| file | Private dependency → exposed CLI | file |
| findutils | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| firewalld | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| fontconfig | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| fwupd | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| fx2lafw | Added by this change | Provided through PulseView/libsigrok; no separate firmware installation needed. |
| gnome keyring | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gnu core utilities | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gnu inetutils | Private/system dependency | Present transitively; no additional legacy networking command set selected. |
| grep | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gvfs | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gzip | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| home manager | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| imagemagick | Private dependency → exposed CLI | imagemagick |
| info-zip | Private dependency → exposed CLI | zip + unzip |
| intel ucode | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| inxi | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| iperf3 | Added by this change | iperf3 |
| iproute2 | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| iputils | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| iw | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| iwd | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| kbd | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| kmod | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| less | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| libinput | Private/system dependency | Input stack is present; no standalone diagnostic CLI selected. |
| linux firmware | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| logical volume manager | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| lsof | Added by this change | lsof |
| man page | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| mesa | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| mesa demos | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| mkinitcpio | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| modemmanager | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| msi-ec | Installed before | Existing hardware-specific MSI control configuration; retain. |
| nftables | Private/system dependency | Dependency is present; firewall remains managed by the existing NixOS configuration. |
| nvidia open | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| pipewire | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| polkit | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| procps | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| psmisc | Private dependency → exposed CLI | psmisc |
| pwgen | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| rclone | Installed before | Configured InfiniCLOUD mounts; retain. |
| ripgrep | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| shadow | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| smartmontools | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| sshfs | Added by this change | sshfs |
| sudo | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| systemd | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| tar | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| tor | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| toybox | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| traceroute | Added by this change | traceroute |
| uncomplicated firewall | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| usb/ip | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| usbutils | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| util-linux | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| vulkan tools | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| wayland | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| wget | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| which | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| whois | Added by this change | whois |
| winfsp | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| wireguard | Deferred | Kernel/NetworkManager support and the standalone wg CLI are different; no VPN configuration selected. |
| wireplumber | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| wl-clipboard | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| wlr-randr | Retained | User explicitly chose to keep it; query works with the current Niri session. |
| xdg desktop portal | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| xdg-utils | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| xhost | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| xwayland-satellite | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| xz utils | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| zoxide | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |

### programs / core terminal environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| armbian config | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| bat | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| bluetui | Skipped | User declined this addition; preserve the decision. |
| btop | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| duf | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| eza | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| fastfetch | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| fzf | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gdu | Added by this change | gdu |
| lazyjournal | Added by this change | lazyjournal |
| microsoft activation scripts | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| networkmanager | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| nvtop | Added by this change | nvtopPackages.full with cudaPackages.cuda_nvml_dev supplying NVML headers; full GPU support without the entire CUDA toolkit. |
| raspi-config | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| systemctl-tui | Added by this change | systemctl-tui |
| trippy | Added by this change | programs.trippy / trip |
| wiremix | Added by this change | wiremix |
| yazi | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| zellij | Added by this change | zellij |

### programs / core wayland environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| amdgpu top | Added by this change | amdgpu_top |
| bulk crap uninstaller | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| chameleon ultra gui | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| dankmaterialshell | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| easyeuicc | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| easylpac | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| fcitx5 | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| ghostty | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gnome | Deferred | Existing Niri session uses selected GNOME components; a full desktop is not selected. |
| gnome files | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| hardinfo2 | Added by this change | hardinfo2 |
| kde connect | Skipped | User declined this addition; preserve the decision. |
| kdiskmark | Retained | User explicitly chose to keep it. |
| kvantum | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| labwc | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| localsend | Added by this change | programs.localsend |
| mangohud | Skipped | User declined this addition; preserve the decision. |
| mcontrolcenter | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| mpv | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| niri | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| nvidia settings | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| nwg-displays | Skipped | User declined this addition; preserve the decision. |
| nwg-look | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| qalculate! | Added by this change | qalculate-gtk |
| qpwgraph | Added by this change | qpwgraph |
| qt5ct | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| qt6ct | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| rime | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| rime-ice | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| satty | Added by this change | satty |
| seahorse | Added by this change | seahorse |
| swayimg | Added by this change | swayimg |
| sylvakru | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| tbtool | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| usbip-win2 | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| windows console | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| windows terminal | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| xdg desktop portal gnome | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| xfce | Project environment | Existing Vitis/Vivado container uses XFCE; no host desktop is added. |

### programs / embedded development environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| armbian | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| bitwuzla | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| buildroot | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| freecad | Added by this change | freecad |
| icarus verilog | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| kicad | Added by this change | kicad |
| nextpnr | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| ngspice | Added by this change | ngspice |
| openfpgaloader | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| openocd | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| openxc7 | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| pulseview | Added by this change | programs.pulseview |
| serial studio | Added by this change | serial-studio (GPL edition) |
| stlink | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| symbiyosys | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| tio | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| verible | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| verilator | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| yocto project | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| yosys | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |

### programs / hacking environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| nmap | Added by this change | nmap |
| wireshark | Added by this change | programs.wireshark / GUI package |
| zenmap | Added by this change | zenmap |

### programs / package management environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| apk | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| appimage | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| apt | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| cargo | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| conan | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| dnf | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| dpkg | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| flatpak | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| magisk module repo loader | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| nix | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| npm | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| pacman | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| paru | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| pip | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| pnpm | Added by this change | pnpm |
| rpm | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| rubygems | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| uv | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| windows package manager | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |

### programs / remote access environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| freerdp | Private dependency → exposed CLI | freerdp (CLI) |
| moonlight | Added by this change | moonlight-qt |
| openssh | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| remmina | Installed before | Existing connection profiles and running applet; retain. |
| sunshine | Skipped | User declined this addition; preserve the decision. |
| wayvnc | Deferred | No installation approved; revisit only for a concrete workflow or device. |

### programs / software development environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| clang | Added by this change | llvmPackages.clang (lower priority for shared aliases) + clang-tools; GCC remains the default cc/c++/cpp. |
| cmake | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| git | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gnu binutils | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gnu compiler collection | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| gnu debugger | Added by this change | gdb for host programs; arm-none-eabi-gdb was already installed with the ARM toolchain. |
| lldb | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| llvm | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| make | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| mingw-w64 | Project scope | Use a project environment when needed; no permanent host toolchain added. |
| msys2 | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| neovim | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| ninja | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| node.js | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| openjdk | Private/system dependency | Existing application JVMs, including STM32CubeMX, remain private; java/javac are not added to the normal user profile. Use a project shell for Java development. |
| shellcheck | Added by this change | shellcheck |
| shfmt | Added by this change | shfmt |

### programs / virtualization environment

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| distrobox | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| docker | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| kernel-based virtual machine | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| libvirt | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| lxc | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| qemu | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| qemu-guest-agent | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| spice | Private/system dependency | Existing virtual-machine integration/dependencies. |
| spice-vdagent | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| swtpm | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| virgl | Deferred | No installation approved; revisit only for a concrete workflow or device. |
| virt-manager | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| virtio-win | Other platform | Targets another OS, Android device, guest, or board; no workstation addition. |
| virtiofs | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |

### proprietary / programs

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |
|  | Deferred | Vendor, hardware, platform, or licensing requirements need a specific project; no installation selected. |

### resources / typefaces

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| font awesome | Added by this change | font-awesome |
| inter | Added by this change | inter |
| jetbrains mono | Installed before | Noto and JetBrains Mono Nerd Font already provide these families. |
| lxgw wenkai | Added by this change | lxgw-wenkai |
| maple mono | Added by this change | maple-mono.NF-CN |
| material design icons | Added by this change | material-icons + material-symbols (Google upstream) |
| nerd fonts | Installed before | Noto and JetBrains Mono Nerd Font already provide these families. |
| noto fonts | Installed before | Noto and JetBrains Mono Nerd Font already provide these families. |
| terminus font | Added by this change | terminus_font |
| zhuque fangsong | Added by this change | Custom pinned v0.212 package |

### services / ai

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| celia | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| chatgpt | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| deepseek | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| deepseek platform | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| google ai studio | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| google antigravity | Skipped | User declined this addition; preserve the decision. |
| google gemini | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| qianwen | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| xiaomi mimo api open platform | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| xiaomi mimo studio | Service website | A bookmark to a web/account service does not establish a missing desktop application. |

### services / cloud infrastructure

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| cloudcone | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| cloudflare | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| dedione | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| justhost | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| spaceship | Service website | A bookmark to a web/account service does not establish a missing desktop application. |

### services / cloud storage

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| infinicloud | Service website | A bookmark to a web/account service does not establish a missing desktop application. |

### services / communication

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| 139 mail | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| china mobile | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| ctexcel | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| dingtalk | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| gmail | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| petal mail | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| redteago | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| telegram | Skipped | User declined this addition; preserve the decision. |
| tencent qq | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| wechat | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| whatsapp | Service website | A bookmark to a web/account service does not establish a missing desktop application. |

### services / connectivity

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| tailscale | Skipped | User declined this addition; preserve the decision. |

### services / content creation

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| google docs editors | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| zotero | Added by this change | zotero |

### services / digital distribution

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| readest | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| steam | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |

### services / finance

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| agricultural bank of china | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| alipay | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| china merchants bank | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| digital renminbi | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| huawei pay | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| industrial and commercial bank of china | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| mastercard | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| unionpay | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| unionpay (application) | Service website | A bookmark to a web/account service does not establish a missing desktop application. |
| wechat pay | Service website | A bookmark to a web/account service does not establish a missing desktop application. |

### services / software development

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| github | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |
| visual studio code | Installed before | Present in the existing configuration, normal user profile, Flatpak, or named development environment. |

### services / video games

| Software or resource | Status / decision | Package or reason |
| --- | --- | --- |
| honor of kings | Service website | A bookmark to a web/account service does not establish a missing desktop application. |

## Validation

The complete system build and `nix flake check --no-build` passed before final activation. **58 recorded checks passed**, including availability of 68 commands and registration of 21 graphical launchers. The flake lockfile is unchanged (SHA-256 `0c97412099609ee39592776d66a9a715b24e9028e291da7cf3c1dc727ce8d871`).

| Area | Result |
| --- | --- |
| System and Home Manager | Generation 112 active; Home Manager completed successfully; DMS remains active. The normal and VFIO system configurations both built. |
| Commands and launchers | All checked commands resolve on the normal user PATH; all 21 checked desktop launchers point to existing executables. LocalSend's executable is `localsend_app`; draw.io's launcher is `drawio.desktop`. |
| Development and electronics | Clang compiles a C++ standard-library header check. Host GDB and ARM tools coexist. KiCad CLI and PulseView version checks pass; libsigrok udev rules are installed. An ngspice voltage-divider simulation passes. |
| Creative applications | Blender starts in background mode with a factory scene; FreeCAD's safe-mode console starts. The other graphical launchers are registered; full interactive workflows were not automated. |
| GPU monitoring | NVTOP's build tests pass, and its runtime snapshot detects the AMD Radeon 610M and NVIDIA GeForce RTX 4060 Laptop GPU. This check established discovery, not availability of every sensor; see the October 5 follow-up. |
| Media | FFmpeg encodes a test video and FFprobe reads it; ImageMagick creates a test PNG. GStreamer finds core/base/good/bad/ugly/libav elements and executes an audio pipeline. |
| Chinese TeX | XeLaTeX and LuaLaTeX compile a Chinese document with LXGW WenKai; Biber generates the bibliography and XeLaTeX compiles the bibliography output. |
| Fonts | Fontconfig finds every added font family, including Zhuque Fangsong. Existing defaults are unchanged. |
| Images and screenshots | All seven MIME defaults resolve to Swayimg. Satty opens a sample image. DMS captures the focused test window and automatically opens the resulting image in Satty. Test windows and the generated screenshot were removed afterward. |
| LocalSend | Active firewall rules allow TCP and UDP port 53317. |
| Capture permissions | `chomsky` is listed in the wireshark group. A subprocess started with the new group can enumerate ten capture interfaces through dumpcap without root. Both dumpcap and Trippy capability wrappers are present. |

Build/runtime corrections included exposing GStreamer's `out` output for core plugins, escaping systemd's percent specifiers in the screenshot-editor setting, and assigning package priorities so Clang and host GDB coexist with the existing GCC/ARM toolchains. NVTOP uses the NVML development package for its NVIDIA headers instead of downloading the complete CUDA toolkit; AMD and NVIDIA monitoring support are retained.

For Chinese TeX documents, use the verified static font with `\setCJKmainfont{LXGW WenKai}`. The existing Noto CJK variable TTC failed these TeX engine checks; it remains available for desktop applications, and no desktop font defaults were changed.

**Log out and back in before using Wireshark capture from the current desktop session.** The group configuration and a fresh-group subprocess were verified; the user's session was not logged out. Instrument access, remote streaming, LAN transfers, and interactive drawing require their respective devices/peers and were not exercised.

The planning estimate was 4.5 GiB of cache downloads and 13.5 GiB unpacked, plus locally built outputs. After the initial installation, the filesystem had approximately **151 GiB free**; the EFI partition had 896 MiB free.

## GPU-monitoring follow-up — 2026-10-05

The btop correction is built, activated, and verified in **generation 114**. Home Manager completed successfully. Active system: `/nix/store/vzhrjj1f6chck8dl57v8q0dxjgy6a1ig-nixos-system-pisces-26.05.20260918.cf9d2fb`.

The user's screenshots exposed two separate issues. The original btop binary had GPU support compiled in, but its runtime search path omitted NVIDIA NVML and AMD ROCm SMI. Its debug log confirmed failure to load both libraries. `home/programs.nix` now enables `cudaSupport` and `rocmSupport` specifically for btop. The ROCm dependency also uses the packaged PCI database instead of a missing `/usr/share/hwdata/pci.ids`, so the AMD chip is identified as **Raphael** rather than **0x1002**. Raphael is the integrated Radeon 610M's chip name. This leaves the user's existing btop preferences editable.

The corrected btop package was tested in a temporary terminal configuration: both GPU panels appeared, both monitoring libraries loaded, and the program exited successfully. AMD name, utilization, temperature, and VRAM queries all returned success; a sample reported 30% utilization and 63°C. The full system build and flake evaluation passed.

NVIDIA telemetry remains **unverified and unavailable until GPU recovery**. Independent `nvidia-smi` queries report `gpu_recovery_action=Reset` and `GPU requires reset` for temperature and performance state. Kernel logs show the first **Xid 119 / GSP RPC timeout** on **October 2 at 19:17 Asia/Shanghai**, before this installation batch, followed by Xid 154 requesting recovery. The cause of that firmware timeout has not been established. NVTOP can still identify the device and read memory while other sensors fail.

NVIDIA documents Xid 119 as a firmware RPC timeout that may require a [GPU reset or power cycle](https://docs.nvidia.com/deploy/xid-errors/analyzing-xid-catalog.html). A [live GPU reset](https://docs.nvidia.com/deploy/nvidia-smi/index.html#r-gpu-reset) requires stopping applications that hold the GPU. Niri currently holds NVIDIA device handles, so live reset would interrupt the desktop. Save work and restart the machine before checking NVIDIA telemetry again. If a restart leaves the same recovery requirement, perform a normal full shutdown and power on; a recurrence then needs further driver/power-management investigation.

After recovery, reopen both monitors and check:

```sh
nvidia-smi --query-gpu=name,gpu_recovery_action,temperature.gpu,utilization.gpu,clocks.gr --format=csv
btop
nvtop
```

In btop, `5` and `6` toggle the two individual GPU panels. Some integrated-GPU fields remain unsupported by ROCm SMI (including the observed memory-utilization, power, and PCIe-throughput queries), and NVTOP's integrated-GPU PCIe/fan fields need not have values. Sensor availability depends on the device and driver API.
