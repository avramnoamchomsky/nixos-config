# 桌面指南

[English](desktop.md) | [简体中文](desktop.zh-CN.md) | [README](../README.zh-CN.md)

Pisces 的桌面同时使用 Home Manager 管理的文件和 DMS 直接写入的设置。
通过[系统重建流程](operations.zh-CN.md#验证与应用)应用仓库修改，修改用户组后需重新登录。
账户与共享桌面配置的位置见[架构指南](architecture.zh-CN.md)。

## 目录

- [桌面配置](#桌面配置)
- [常用快捷键](#常用快捷键)
- [Shell、终端与模糊效果](#shell终端与模糊效果)
- [应用与系统集成](#应用与系统集成)
- [桌面主题](#桌面主题)
- [微信](#微信)、[WPS Office](#wps-office)与 [Ghost Downloader](#ghost-downloader)
- [百度网盘](#百度网盘)、[115 生活](#115-生活)与 [115 浏览器](#115-浏览器)
- [Readest](#readest) 与 [SylvaKru](#sylvakru)
- [Steam 与 Bottles](#steam-与-bottles)
- [Fish 与归档命令](#fish-与归档命令)

## 桌面配置

在 `tty1` 上以 `chomsky` 登录即可启动 Niri 和 DMS，登录钩子在
[Pisces 账户文件](../hosts/Pisces/users/chomsky.nix)中。退出 Niri 后会返回登录提示。
按 `Ctrl+Alt+F2` 可切换到登录后停留在 Fish 的控制台。

Flake 固定使用 Dux Modular Shell（DMS）官方发行版 `v2.1.2`。DMS 设置将快捷键、
窗口规则、输入设置、光标、显示器、布局、配色、最近窗口和壁纸集成写入可写状态。
使用默认 XDG 路径时，其中的 Niri 片段位于 `~/.config/niri/dms/`。

Home Manager 使用上游模板生成 Niri 主配置，并加载 [home/niri/](../home/niri) 中的
尺寸预设和模糊规则。[home/niri.nix](../home/niri.nix) 还提供 Adwaita 后备光标，
并关闭鼠标中键和触控板三指轻触触发的主选区粘贴。普通剪贴板快捷键仍可使用。
上游模板通过 `prefer-no-csd` 请求使用服务端窗口装饰。

首次激活时，DMS 与 Niri 会将已有偏好和片段备份到同级 `*-before-stock.*` 目录，
再初始化发行版默认配置和仓库中的本地设置。`~/.local/state/` 下的迁移标记
让日常重建保留已修改的偏好。窗口截图的剪贴板修正也适用于已有配置中匹配的默认绑定。

Wood Whale 头像和壁纸集合位于 [Pisces 资源目录](../hosts/Pisces/assets)。
[账户的 DMS 模块](../hosts/Pisces/users/dms.nix)通过 AccountsService 设置头像，
将壁纸集合链接至 `~/Pictures/Wallpapers`，并在首次激活时设置粉色玫瑰壁纸。

Fcitx5 的配置中只保留 MSIME。[home/input-method.nix](../home/input-method.nix)
管理此配置，保留 US 物理键盘布局并将 MSIME 设为默认输入法。长期修改应写入该文件。
当前配置已移除 Rime 与 Rime Ice。

UDisks 和 Home Manager 的 `udiskie` 服务会将符合条件的可移动存储挂载到
`/run/media/chomsky/`。Home Manager 也会创建标准 XDG 用户目录，并提供通过 Ghostty
启动 Neovim 的 `nvim.desktop` 条目。

## 常用快捷键

`Mod+Shift+Slash` 打开 DMS 快捷键列表，`Mod+Comma` 打开设置。
在 Niri 桌面中，`Mod` 默认为 Super。

| 快捷键 | 操作 |
| --- | --- |
| `Mod+T` 或 `Mod+Return` | 打开 Ghostty |
| `Mod+Space` | 打开应用启动器 |
| `Mod+D` | 切换仪表板 |
| `Mod+V` | 切换剪贴板管理器 |
| `Mod+Alt+L` | 锁屏 |
| `Mod+O` 或 `Mod+Tab` | 切换概览 |
| `Alt+Tab` | 切换最近窗口 |
| `Mod+1` 至 `Mod+9` | 切换工作区 |
| `Mod+Shift+1` 至 `Mod+Shift+9` | 将列移至工作区 |
| `Mod+R` | 在 50% 和 95% 之间切换列宽 |
| `Mod+Shift+R` | 在 50% 和 100% 之间切换窗口高度 |
| `Print` / `Ctrl+Print` / `Alt+Print` | DMS 截取区域 / 当前输出 / 当前窗口 |
| `Mod+Print` | 启动 DMS 滚动截图（Pisces 自定义绑定） |
| `Mod+Shift+P` | 关闭显示器 |

上表包含初始化绑定，以及 Pisces 在可写片段 `~/.config/niri/dms/binds.kdl` 中
设置的自定义 `Mod+Print`。当前配置使用的绑定可在 DMS 快捷键列表中查看。

运行 `dms screenshot scroll` 可开始滚动截图。框选区域后，在应用内用鼠标滚轮或
触控板滚动，按 `Enter` 完成或按 `Esc` 取消。Niri 下滚动截图要求输出未旋转。
如需在新配置中恢复 Pisces 的快捷键，在可写片段的 `binds { ... }` 内添加以下行，
再运行 `niri validate`。

```kdl
Mod+Print repeat=false hotkey-overlay-title="Screenshot: Scroll" { spawn "dms" "screenshot" "scroll"; }
```

`screenshot-path null` 关闭 Niri 自身的截图文件保存。截取窗口时，Niri 提供剪贴板副本，
DMS 保存文件。

## Shell、终端与模糊效果

Fish 是登录 Shell，启动时不显示欢迎语。运行 `bash` 可进入交互式 Bash。
两个 Shell 都采用 Starship 的 **Gruvbox Rainbow** 预设，并集成 zoxide、fzf、Eza
和 Yazi。Bash 使用 ble.sh 提供行内建议和实时高亮，并通过 bash-completion 提供
命令专用补全。在普通终端中，fzf 和 zoxide 也会加载 ble.sh 集成。

Ghostty 使用 Gruvbox Dark、JetBrains Mono Nerd Font、40% 背景不透明度和蓝白光标拖尾。
Ghostty 主题和光标着色器独立于 Starship 提示符主题。

| 修改内容 | 位置 |
| --- | --- |
| Ghostty 不透明度或着色器设置 | [home/programs.nix](../home/programs.nix) 中的 `programs.ghostty.settings` |
| Ghostty 光标拖尾颜色 | [home/ghostty/cursor-trail.glsl](../home/ghostty/cursor-trail.glsl) |
| Swayimg 背景不透明度 | [home/programs.nix](../home/programs.nix) 中 Swayimg 的浏览、幻灯片及图库配置。`#28282866` 表示 40% 不透明度 |
| 各应用的 Niri X-ray 模糊 | [Ghostty 规则](../home/niri/ghostty-blur.kdl)和 [Swayimg 规则](../home/niri/swayimg-blur.kdl) |

不透明度决定应用透出多少背景。X-ray 模糊透过窗口堆叠采样壁纸，
详见 [Niri 窗口效果](https://github.com/niri-wm/niri/wiki/Window-Effects)。
持久修改通过[系统重建流程](operations.zh-CN.md#验证与应用)应用。

## 应用与系统集成

`home/programs.nix` 声明大多数用户应用与命令；`system/desktop.nix` 提供
服务、设备访问、字体及能力包装器。[带日期的软件审计](software-audit-2026-10-04.md)
记录安装决策；当前安装内容以 Nix 模块为准。

| 类别 | 应用或集成 |
| --- | --- |
| 创作 | GIMP、Blender、Audacity、Kdenlive、OBS Studio、draw.io、Freeplane 与 Zotero |
| 电子 | KiCad、FreeCAD、Serial Studio、ngspice 与 PulseView；PulseView 提供 libsigrok USB 规则 |
| 网络 | LocalSend（`localsend_app`，TCP/UDP `53317`）、Nmap/Zenmap、iperf3、Wireshark、Trippy（`trip`）、SSHFS、FreeRDP、Remmina 与 Moonlight |
| 代理核心 | 从稳定版 Nixpkgs 系统级安装 sing-box 命令行工具；未配置代理服务 |
| 抓包权限 | Wireshark 的 `dumpcap` 包装器允许 `wireshark` 组成员抓取网络流量；USB 抓包关闭。Trippy 使用 NixOS 能力包装器 |
| 监控 | 启用 NVML/ROCm SMI 的 btop、NVTOP、amdgpu_top 与 HardInfo2；见[显卡诊断](operations.zh-CN.md#混合显卡与监控) |
| 媒体命令 | FFmpeg/FFprobe、ImageMagick、GStreamer 及 base/good/bad/ugly/libav 插件 |
| mpv | ModernZ 提供屏幕控制条，内置 OSC 已关闭以避免重复 |
| Nautilus | Sushi 通过 `Space` 预览选中文件。Open Any Terminal 在选中的本地目录打开 Ghostty |
| 默认应用 | Chrome 打开 HTTP/HTTPS、HTML 与 PDF；WPS 打开 Microsoft Office 格式；Swayimg 打开 PNG/JPEG/GIF/WebP/BMP/TIFF/AVIF |
| 字体 | Noto/CJK/emoji、JetBrains Mono Nerd Font、Inter、LXGW WenKai、Maple Mono NF-CN、Font Awesome、Material Icons/Symbols、Terminus 及固定的朱雀仿宋 `0.212` |

修改 `wireshark` 组后请注销并重新登录。已安装软件包不代表外设、远程节点或每项
GPU 传感器均已验证。中文 TeX 设置见[开发指南](development.zh-CN.md#中文-tex)。

Yazi 通过 [home/yazi.nix](../home/yazi.nix) 加载 `compress`、`full-border`、`git`、
`mount` 和 `zoom`。`M` 打开挂载管理器，先按 `g` 再按 `+` 或 `-` 缩放图片预览，
`c a a` 压缩所选文件。`c a p` 请求密码，`c a h` 同时加密归档头，`c a l` 选择压缩级别，
`c a u` 打开完整归档选项。

Pisces 的 GVfs 不会自动发现托管的 WebDAV 挂载，以免拖慢本地文件选择器。两个共享仍可通过
`~/mnt` 直接打开。挂载诊断见[机密与 WebDAV](operations.zh-CN.md#机密与-webdav)。

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
- KiCad 及其编辑器通过 `home/programs.nix` 中的软件包启动器单独使用
  [WhiteSur](https://github.com/vinceliuice/WhiteSur-gtk-theme)（`WhiteSur-Dark`），
  包括应用菜单和文件关联启动。仅这些启动器设置 `GTK_THEME` 并加入 WhiteSur
  的数据目录；该主题不会安装到共享 profile，其他应用继续使用上述桌面主题。

生成的 GTK、qt5ct、qt6ct 与 Kvantum 文件均由 Home Manager 管理。持久修改应写入
`home/themes.nix`；图形工具可能无法直接保存到这些受管理文件。

## 微信

Home Manager 安装官方[微信 Linux 版](https://linux.weixin.qq.com/)的
`4.1.13.26` x86_64 AppImage，版本与 SHA-256 固定在
`packages/wechat.nix` 中，并复用 Nixpkgs 的微信 AppImage 打包方式和
FHS 运行环境。腾讯会在发布更新时替换下载链接对应的文件；升级时应同时
更新版本与哈希。

`wechat` 启动器选择 XWayland 和 Fcitx，以支持 Niri 中的中文输入。
应用配置后，完全退出并重新打开微信即可使用新版本。

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
SHA-256 固定在 `packages/ghost-downloader.nix` 中。软件包为自带的
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

## 百度网盘

Home Manager 从 x86_64 Debian 软件包安装
[官方百度网盘 Linux 客户端](https://pan.baidu.com/download) `8.7.0`，
SHA-256 固定在 `packages/baidunetdisk.nix` 中。软件包保留自带的
Electron，为 NixOS 修补可执行文件的解释器，并通过启动器提供 GTK 2 和 GTK 3
依赖。自带的共享库保持原样，因为原生启动完整性检查会在库文件被修改时退出。
启动器在 Niri 下选择 XWayland 和 Fcitx，以支持中文输入，并保留厂商
默认的 `--no-sandbox` 启动参数。

应用配置后，可从应用菜单启动 **百度网盘**（**Baidu Netdisk**），或运行
`baidunetdisk`，再使用百度账号或扫描登录二维码登录。
`home/baidunetdisk.nix` 将 `baiduyunguanjia://` 链接注册到同一个打包的
桌面启动器。

账号数据、设置和下载历史保存在用户目录中，保持可写且不进入 Git。升级时
修改固定的软件包版本与哈希，再重新构建 NixOS。

## 115 生活

[官方 115 生活 37.3.1 Linux 版](https://115.com/115/T984564.html) 在
`packages/115-life.nix` 中固定版本和 SHA-256，并通过
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
`packages/115-browser.nix` 中以声明式方式打包。版本 `35.30.0` 及下载
哈希已固定，厂商二进制文件已适配 NixOS。由于其传输管理器在 Niri 原生
Wayland 下显示异常，该应用会强制通过 XWayland 运行。可通过应用启动器或
`115-browser` 命令运行。

该厂商版本报告其 Chromium 版本为 `125.0.6422.61`，版本较旧。建议仅用于
115 专属功能；日常网页浏览仍使用默认的 Google Chrome。

浏览器无法更新 Nix store 中的只读文件。升级时需要修改软件包定义中的
版本、官方下载地址及哈希，然后重新构建系统。

## Readest

[Readest](https://github.com/readest/readest) 使用
`packages/readest.nix` 中固定的上游 `0.12.10` 版本构建原生 Nix 软件包，
并使用 `nixpkgs-unstable` 软件包集提供依赖，以避免上游 AppImage 在
Wayland 下的库兼容问题。可通过应用启动器或 `readest` 命令运行。
软件包默认关闭自动更新检查与遥测；升级时需更新软件包版本及哈希。

## SylvaKru

[SylvaKru](https://github.com/AfalpHy/sylvakru) 通过
`packages/sylvakru.nix` 中固定的官方 x86_64 Linux 版本安装。厂商软件
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

`7zz` 和 `7z` 调用同一个 7-Zip 软件包。Fish 的 `7zip` 与 `7sec` 别名使用
LZMA2 最高压缩等级，`7zipv` 和 `7secv` 按 100 GiB 分卷。这些别名在
[账户文件](../hosts/Pisces/users/chomsky.nix)中定义。

`7sec` 别名使用仓库中可读取的口令加密文件内容和文件名。制作私密归档时，直接
使用 `7z` 并添加 `-p -mhe=on`，在提示中输入私有口令。
