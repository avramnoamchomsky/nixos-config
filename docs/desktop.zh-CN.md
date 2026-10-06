# 桌面指南

[English](desktop.md) | [简体中文](desktop.zh-CN.md) | [README](../README.zh-CN.md)

Home Manager 管理本指南中的桌面文件与资源。请通过
[系统重构流程](operations.zh-CN.md#验证与应用)应用修改，并通过重新登录获取
变更后的用户组成员身份。Shell 示例使用 Bash；从 Fish 执行下方头像示例前，
请先运行 `bash`。

## 目录

- [声明式桌面状态](#声明式桌面状态)与 [DMS 头像](#dms-头像)
- [常用快捷键](#常用快捷键)
- [应用与系统集成](#应用与系统集成)
- [桌面主题](#桌面主题)
- [WPS Office](#wps-office)、[Ghost Downloader](#ghost-downloader)、[115 生活](#115-生活)与 [115 浏览器](#115-浏览器)
- [Readest](#readest) 与 [SylvaKru](#sylvakru)
- [Steam 与 Bottles](#steam-与-bottles)
- [Fish 与归档命令](#fish-与归档命令)

## 声明式桌面状态

- Niri 仅读取 `~/.config/niri/config.kdl`，该文件由
  `home/niri/config.kdl` 部署。
- DMS 生成的可选 Niri 配置片段未被使用，并会被自动清理。
- 经过审阅的 DMS 设置保存在 `home/dms/settings.json` 中。
- DMS 头像由 `home/dms.nix` 声明，使用 `home/dms/Wood_Whale.jpg`；
  详见下方的 [DMS 头像](#dms-头像)。
- 指定的 DMS 会话偏好通过声明式方式合并；历史记录、检测到的设备及其他
  易变状态仍可由程序写入。
- `home/wallpapers/` 中的壁纸会被部署到 `~/Pictures/Wallpapers`。
  DMS 根据当前所选壁纸的路径确定壁纸轮换目录。
- UDisks 在系统层处理可移动存储，Home Manager 的 `udiskie` 服务会将符合
  条件的文件系统自动挂载到 `/run/media/chomsky/`；被 UDisks 标记为忽略的
  分区不会自动挂载。
- Home Manager 会声明标准 XDG 用户目录，并创建缺失的 `Documents`、
  `Downloads`、`Music` 和 `Pictures` 等目录；这也会提供 SylvaKru 等 Flutter
  桌面应用所需的路径。
- `nvim.desktop` 会显式地在 Ghostty 中启动 Neovim，使 Nautilus 文件关联
  无需依赖 GLib 在精简的 Niri 会话中自动发现终端模拟器。

受管理路径与可写状态采用不同的更新规则：

| 状态 | 来源与行为 |
| --- | --- |
| Niri 配置 | `home/niri/config.kdl` 部署为只读 Home Manager 链接 |
| DMS 设置与剪贴板偏好 | `home/dms/settings.json` 与 `home/dms.nix` 生成只读配置文件 |
| DMS 会话 | `~/.local/state/DankMaterialShell/session.json` 保持可写；激活时恢复声明的主题/夜间模式偏好及粉色玫瑰壁纸，保留其他字段 |
| 主题、输入法、MIME 默认值与 MSI 偏好 | 编辑 `home/themes.nix`、`home/input-method.nix` 或 `home/desktop.nix`；生成文件由 Home Manager 管理 |
| 应用数据 | 浏览器 profile、账户、资料库及下载历史保留在 Git 之外 |

已有 DMS 会话 JSON 无效时，激活会停止而不是替换它；修复前请检查并备份该状态文件。
要持久修改默认壁纸，请修改 `home/dms.nix` 中的 `wallpaperPath`，并将图片加入
`home/wallpapers/`。

### DMS 头像

Wood Whale 原始 JPEG 保存在 `home/dms/Wood_Whale.jpg` 中，并由 Git 管理；
构建使用仓库内的副本，不依赖 `~/Downloads`。`home/dms.nix` 通过 ImageMagick
在 Nix store 中生成尺寸不超过 512×512 的 PNG，保留原图构图并移除元数据。较小的图片
符合 AccountsService 的 1 MiB 头像限制，原始 JPEG 保持不变。

Home Manager 的 `dmsProfileImage` 激活钩子通过 AccountsService 查找配置的
用户，并设置其 `IconFile`。NixOS 原生 DMS 模块会启用 AccountsService。
如果 `dms.service` 正在运行，钩子还会调用 DMS 的头像 IPC，立即刷新缓存
图片；如果 shell 未运行，则会在下次启动时读取账户头像。设置窗口、仪表板、
控制中心及锁屏共用该头像；其他读取 AccountsService 头像的应用也会看到它。

如需更换声明式头像，替换 `home/dms/Wood_Whale.jpg`，或修改 `home/dms.nix`
中的 `profileImage` 源文件，然后按照[验证与应用](operations.zh-CN.md#验证与应用)执行。
如果使用新文件，应先将其加入 Git 暂存区，使 Nix 在求值 flake 时包含该文件。
在 DMS 设置界面中选择头像只是临时修改；下次 Home Manager 激活时，会恢复
仓库声明的图片。

激活后，以普通用户执行以下命令，检查账户头像与正在运行的 shell：

```bash
account_path=$(busctl --system --json=short call \
  org.freedesktop.Accounts /org/freedesktop/Accounts \
  org.freedesktop.Accounts FindUserByName s "$USER" | jq -r '.data[0]')
busctl --system get-property org.freedesktop.Accounts "$account_path" \
  org.freedesktop.Accounts.User IconFile
dms ipc call profile getImage
```

AccountsService 通常返回 `/var/lib/AccountsService/icons/chomsky`，该文件
是生成 PNG 的副本。正在运行的 DMS 可能返回此路径，也可能返回 Nix store 中
生成的 `dms-wood-whale-avatar.png` 路径；两者应显示同一张图片。

## 常用快捷键

以下按键名称与 `home/niri/config.kdl` 一致。使用 `Mod+Shift+Slash` 打开 Niri
快捷键提示，查看完整列表。

| 快捷键 | 操作 |
| --- | --- |
| `Mod+T` | 打开 Ghostty |
| `Mod+D` | 切换 DMS 应用启动器 |
| `Super+Alt+L` | 锁屏 |
| `Mod+O` | 切换概览 |
| `Mod+Q` | 关闭当前窗口 |
| `Mod+H/J/K/L` 或 `Mod+Arrow` | 切换相邻列/窗口的焦点 |
| `Mod+Ctrl+H/J/K/L` 或 `Mod+Ctrl+Arrow` | 移动当前列/窗口 |
| `Mod+1` 至 `Mod+9` | 切换工作区 |
| `Mod+Ctrl+1` 至 `Mod+Ctrl+9` | 将列移至工作区 |
| `Mod+F` / `Mod+Shift+F` | 最大化列 / 窗口全屏 |
| `Mod+V` | 切换浮动状态 |
| `Print` / `Ctrl+Print` / `Alt+Print` | DMS 交互式 / 屏幕 / 窗口截图，然后由 Satty 编辑 |
| `Mod+Shift+P` | 关闭显示器 |
| `Mod+Shift+E` 或 `Ctrl+Alt+Delete` | 退出 Niri |

关闭显示器后系统仍继续运行。音量、媒体、麦克风静音及亮度键使用 DMS IPC，
锁屏时也可使用。

## 应用与系统集成

`home/programs.nix` 声明大多数用户应用与命令；`system/desktop.nix` 提供
服务、设备访问、字体及能力包装器。[带日期的软件审计](software-audit-2026-10-04.md)
记录安装决策；当前安装内容以 Nix 模块为准。

| 类别 | 应用或集成 |
| --- | --- |
| 创作 | GIMP、Blender、Audacity、Kdenlive、OBS Studio、draw.io、Freeplane 与 Zotero |
| 电子 | KiCad、FreeCAD、Serial Studio、ngspice 与 PulseView；PulseView 提供 libsigrok USB 规则 |
| 网络 | LocalSend（`localsend_app`，TCP/UDP `53317`）、Nmap/Zenmap、iperf3、Wireshark、Trippy（`trip`）、SSHFS、FreeRDP、Remmina 与 Moonlight |
| 抓包权限 | Wireshark 的 `dumpcap` 包装器允许 `wireshark` 组成员抓取网络流量；USB 抓包关闭。Trippy 使用 NixOS 能力包装器 |
| 监控 | 启用 NVML/ROCm SMI 的 btop、NVTOP、amdgpu_top 与 HardInfo2；见[显卡诊断](operations.zh-CN.md#混合显卡与监控) |
| 媒体命令 | FFmpeg/FFprobe、ImageMagick、GStreamer 及 base/good/bad/ugly/libav 插件 |
| 默认应用 | Chrome 打开 HTTP/HTTPS、HTML 与 PDF；WPS 打开 Microsoft Office 格式；Swayimg 打开 PNG/JPEG/GIF/WebP/BMP/TIFF/AVIF |
| 字体 | Noto/CJK/emoji、JetBrains Mono Nerd Font、Inter、LXGW WenKai、Maple Mono NF-CN、Font Awesome、Material Icons/Symbols、Terminus 及固定的朱雀仿宋 `0.212` |

修改 `wireshark` 组后请注销并重新登录。已安装软件包不代表外设、远程节点或每项
GPU 传感器均已验证。中文 TeX 设置见[开发指南](development.zh-CN.md#中文-tex)。

## 桌面主题

- GTK 2/3 使用 `MacTahoe-Dark-nord`，可通过 `nwg-look` 查看和选择。
- Qt 5/6 使用 `qt5ct`/`qt6ct` 作为平台配置层，并使用
  `MacTahoeDark` Kvantum 主题；仍可通过 `kvantummanager` 查看配置。
- 两个主题均从官方
  [MacTahoe GTK](https://github.com/vinceliuice/MacTahoe-gtk-theme) 与
  [MacTahoe KDE](https://github.com/vinceliuice/MacTahoe-kde) 仓库的固定
  revision 构建。
- GTK 4/libadwaita 通过 Home Manager 的显式 CSS 导入变通方案使用同一
  主题。GTK 4 并不正式支持第三方主题，因此部分应用仍可能存在显示差异。

生成的 GTK、qt5ct、qt6ct 与 Kvantum 文件均由 Home Manager 管理。持久修改应写入
`home/themes.nix`；图形工具可能无法直接保存到这些受管理文件。

## WPS Office

Home Manager 从稳定版 `wpsoffice-cn` 软件包安装中文个人版，当前固定为
`12.1.2.25882`。文字（`wps`）、表格（`et`）、演示（`wpp`）及 PDF
（`wpspdf`）启动器会显式选择 XWayland 和 Fcitx，以支持 Niri 中的中文
输入。应用菜单入口使用相同的包装启动器；中文显示使用系统已有的
Noto CJK 字体。

WPS 是 Microsoft Word、PowerPoint 和 Excel 文件的默认打开方式，包括
模板及启用宏的文档格式；默认关联同时覆盖标准 MIME 类型和 WPS 自定义
MIME 类型。Google Chrome 继续作为默认浏览器，并默认打开 PDF 文件。

应用配置后，可从应用菜单或使用 `wps` 启动。

## Ghost Downloader

Home Manager 从官方 x86_64 AppImage 安装
[Ghost Downloader v4.3.7](https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/tag/v4.3.7)，
SHA-256 固定在 `home/packages/ghost-downloader.nix` 中。软件包为自带的
Python 和 Qt 库提供 FHS 环境，并提供用于媒体下载的 FFmpeg。
可从终端运行 `ghost-downloader`，或从应用菜单启动 **Ghost Downloader**。
`home/ghost-downloader.nix` 将 `ghostdownloader://` 协议注册到 Nix 包装器，
使浏览器链接使用同一个可工作的启动程序。

应用设置、下载历史和功能包保存在 `~/.local/share/GhostDownloader/` 中，
保持可写。首次安装时启用 TLS 证书校验，并关闭应用更新检查。升级时修改
软件包固定的版本和校验和，再重新构建 NixOS；后续重建会保留在应用内修改
的设置。

如需浏览器下载拦截，可安装可选的
[Ghost Downloader for Browser 扩展](https://chromewebstore.google.com/detail/ghost-downloader-for-brow/lagbjgkmaafnlinaeonbhjchnjinjpeh)，
并通过 Ghost Downloader 的设置向导或浏览器集成设置完成配对。桌面应用
可以独立于该扩展运行。

## 115 生活

[官方 115 生活 37.3.1 Linux 版](https://115.com/115/T984564.html) 在
`home/packages/115-life.nix` 中固定版本和 SHA-256，并通过
`home/115-life.nix` 安装。软件包保留自带的 .NET 运行时与 ICU 库，
为 NixOS 修补原生二进制文件，并提供 Avalonia 所需的 X11 库、
WebKitGTK 4.1、密钥存储、通知及媒体依赖。在 Niri 下通过 XWayland 运行。

可从应用菜单启动 **115生活**，或运行 `115-life`（也可使用 `115life`），
再使用 115 账号或扫描登录二维码登录。`life115://` 协议使用同一个 Nix
启动包装器。种子文件可通过“打开方式”选择此应用，默认关联仍由用户选择。

设置及账号数据保存在用户目录中，保持可写。升级时修改软件包固定的版本
与哈希，再重新构建 NixOS。

## 115 浏览器

[官方 x86_64 Linux 版](https://q.115.com/115/T888199.html) 115 浏览器在
`home/packages/115-browser.nix` 中以声明式方式打包。版本 `35.30.0` 及下载
哈希已固定，厂商二进制文件已适配 NixOS。由于其传输管理器在 Niri 原生
Wayland 下显示异常，该应用会强制通过 XWayland 运行。可通过应用启动器或
`115-browser` 命令运行。

该厂商版本报告其 Chromium 版本为 `125.0.6422.61`，版本较旧。建议仅用于
115 专属功能；日常网页浏览仍使用默认的 Google Chrome。

浏览器无法更新 Nix store 中的只读文件。升级时需要修改软件包定义中的
版本、官方下载地址及哈希，然后重新构建系统。

## Readest

[Readest](https://github.com/readest/readest) 使用
`home/packages/readest.nix` 中固定的上游 `0.12.10` 版本构建原生 Nix 软件包，
并使用 `nixpkgs-unstable` 软件包集提供依赖，以避免上游 AppImage 在
Wayland 下的库兼容问题。可通过应用启动器或 `readest` 命令运行。
软件包默认关闭自动更新检查与遥测；升级时需更新软件包版本及哈希。

## SylvaKru

[SylvaKru](https://github.com/AfalpHy/sylvakru) 通过
`home/packages/sylvakru.nix` 中固定的官方 x86_64 Linux 版本安装。厂商软件
包已适配 NixOS，并提供 GTK、系统托盘、机密存储、OpenGL 与 mpv 运行库。
它支持本地音乐，以及通过 WebDAV、Navidrome 和 Emby 访问自托管音乐库。
可通过应用启动器或 `sylvakru` 命令运行。

软件包当前固定为 `3.6.0`。升级时需要修改软件包定义中的版本、官方发布
地址及哈希。

## Steam 与 Bottles

`system/gaming.nix` 启用 Steam、protontricks、Proton GE、GameMode、gamescope
及 Steam 硬件规则。正常启动时可通过 `nvidia-offload` 使用 NVIDIA；VFIO 启动则
将它预留给客户机。

[Bottles](https://usebottles.com/) 通过固定的 `nix-flatpak` flake 输入，以
上游正式支持的 Flatpak 形式安装。Flathub 与
`com.usebottles.bottles` 应用在 `system/desktop.nix` 中声明，并由每周
定时器更新；不再使用的 Flatpak runtime 会自动清理。Flathub 远程源使用
中科大中国大陆缓存；管理服务会在安装或更新前，将已有远程源同步到该
地址。

Flatpak 应用以收敛方式管理，并不存储在 Nix generation 中，因此回退
NixOS 不会同时回退 Bottles。Bottles 仍处于沙箱内；应通过文件 portal
单独授权游戏目录，而不是开放整个主目录。需要时可在每个 bottle 的图形
设置中选择 NVIDIA 独立显卡。

## Fish 与归档命令

系统还安装了目前维护的上游 7-Zip CLI。`7zz` 与兼容命令 `7z` 均可使用，
两者都会调用固定 Nixpkgs 输入中的同一软件包。Fish 提供使用
LZMA2 最高压缩等级的 `7zip` 与 `7sec` 别名，以及按 100 GiB 分卷的
`7zipv` 与 `7secv`。`7sec` 系列使用已配置的便捷口令同时加密文件内容和文件名。

归档别名在 `home/programs.nix` 中定义；`7sec` 系列使用该源文件中的固定口令。
需要保密的归档应显式选择私有密码。
