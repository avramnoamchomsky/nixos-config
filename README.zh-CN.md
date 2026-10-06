# NixOS 配置

[English](README.md) | [简体中文](README.zh-CN.md)

用于 `pisces` 笔记本及 `chomsky` 用户环境的声明式配置。

## 主要特性

- 使用 NixOS flakes，并将 Home Manager 集成到系统重构流程中
- 使用 `linuxPackages_latest`，当前固定为 Linux `7.1.8`
- 使用 Niri，并由 Git 完整管理其 KDL 配置
- 使用 Dank Material Shell，管理经过审阅的设置、声明式 Wood Whale 头像及壁纸
- AMD + NVIDIA 混合显卡，以及可在启动时选择的 RTX 4060 VFIO 模式
- 在 AMD 平台恢复问题修复前禁用系统睡眠
- Fcitx5 与 Rime Ice 输入法
- PipeWire、NetworkManager、蓝牙及 Avahi/mDNS
- 由 libvirt 与 virt-manager 管理的 KVM/QEMU 虚拟化环境
- Docker 与 Distrobox，以及基于 Ubuntu 22.04 的 Vitis/Vivado 2023.2 环境
- 通过 UDisks 与 udiskie 自动挂载可移动存储设备
- 来自已审阅书签清单的创作、电子、网络诊断及排版工具
- Fish 和桌面应用，包括 WPS Office 中文个人版、Ghost Downloader、Raspberry Pi Imager、Remmina、SylvaKru、Readest、115 生活、115 浏览器及作为默认浏览器的 Google Chrome
- 声明式 MacTahoe GTK 与 Kvantum 主题，以及 nwg-look、qt5ct 和 qt6ct
- ESP32 与 STM32 开发工具、direnv 及硬件访问规则
- 使用 sops-nix 加密机密，并由仅存在于本机的 age 身份密钥解密
- 自动挂载两个 InfiniCLOUD WebDAV 账户

## 目录结构

```text
.
├── flake.nix
├── flake.lock
├── system
│   ├── default.nix
│   ├── desktop.nix
│   ├── fpga.nix
│   ├── gaming.nix
│   ├── hardware-configuration.nix
│   ├── hybrid-graphics.nix
│   ├── msi-control.nix
│   ├── power-management.nix
│   ├── secrets.nix
│   ├── vfio.nix
│   └── virtualization.nix
├── home
│   ├── default.nix
│   ├── 115-life.nix
│   ├── desktop.nix
│   ├── dms.nix
│   ├── dms
│   │   ├── settings.json
│   │   └── Wood_Whale.jpg
│   ├── ghost-downloader.nix
│   ├── input-method.nix
│   ├── niri.nix
│   ├── niri
│   │   └── config.kdl
│   ├── packages
│   │   ├── 115-browser.nix
│   │   ├── 115-life.nix
│   │   ├── ghost-downloader.nix
│   │   ├── readest.nix
│   │   ├── sylvakru.nix
│   │   └── zhuque-fangsong.nix
│   ├── programs.nix
│   ├── rclone.nix
│   ├── themes.nix
│   ├── vitis.nix
│   └── wallpapers
│       └── ...
├── docs
│   └── software-audit-2026-10-04.md
├── secrets
│   └── webdav.yaml
├── .sops.yaml
├── .gitignore
├── README.md
└── README.zh-CN.md
```

`system/` 包含系统级硬件、启动、网络、服务、安全及机密解密配置；
`home/` 包含由 `chomsky` 账户管理的应用程序及用户配置。

## 挂起与休眠

`system/power-management.nix` 禁用 s2idle、S4、混合睡眠及“先挂起后休眠”。
目前不再计划启用休眠，AMD 平台恢复问题也尚未解决。盒盖动作被设置为
`ignore`，DMS 不显示挂起或休眠操作，以防止意外进入无法恢复的状态。

日常内存压力仅由 zram 处理。原来的 72 GiB `/var/lib/swapfile` 已从
配置中移除，停用后可以删除；NixOS 不会根据当前配置重新创建该文件。

基于 systemd 的 initrd 仍保持启用。应用配置后，可执行以下命令验证
交换设备和禁用睡眠的策略：

```bash
swapon --show
systemd-analyze cat-config systemd/sleep.conf | grep '^Allow'
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager CanSuspend
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager CanHibernate
```

`swapon --show` 应只列出 `/dev/zram0`。四个 `Allow*` 设置均应为 `false`，
两个 bus 调用都应返回 `s "no"`。

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

### DMS 头像

Wood Whale 原始 JPEG 保存在 `home/dms/Wood_Whale.jpg` 中，并由 Git 管理；
构建使用仓库内的副本，不依赖 `~/Downloads`。`home/dms.nix` 通过 ImageMagick
在 Nix store 中生成 512×512 PNG，保留原图构图并移除元数据。较小的图片
符合 AccountsService 的 1 MiB 头像限制，原始 JPEG 保持不变。

Home Manager 的 `dmsProfileImage` 激活钩子通过 AccountsService 查找配置的
用户，并设置其 `IconFile`。NixOS 原生 DMS 模块会启用 AccountsService。
如果 `dms.service` 正在运行，钩子还会调用 DMS 的头像 IPC，立即刷新缓存
图片；如果 shell 未运行，则会在下次启动时读取账户头像。设置窗口、仪表板、
控制中心及锁屏共用该头像；其他读取 AccountsService 头像的应用也会看到它。

如需更换声明式头像，替换 `home/dms/Wood_Whale.jpg`，或修改 `home/dms.nix`
中的 `profileImage` 源文件，然后按照[验证与应用](#验证与应用)执行。
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

## 已审阅的软件新增

[2026-10-04 软件审计](docs/software-audit-2026-10-04.md)记录了书签清单、
已批准的新增软件、现有依赖、跳过的工具、暂缓的集成及清理决策。用户应用
和命令在 `home/programs.nix` 中声明；系统权限和字体在 `system/desktop.nix`
中声明。现有 flake 输入保持固定。

PulseView 使用 NixOS 模块提供的 libsigrok USB 规则。LocalSend 开放 TCP/UDP
端口 `53317`。Wireshark 安装完整的图形与命令行软件包，并通过 `wireshark`
组授予网络抓包权限；USB 抓包保持关闭。激活后需注销并重新登录，以获得新
用户组成员身份。Trippy 通过 NixOS 的 `trip` 能力包装器运行。

btop 同时启用 NVIDIA NVML 与 AMD ROCm SMI 检测；ROCm 依赖使用软件包提供
的 PCI 数据库显示 GPU 名称。在 btop 中，`5` 和 `6` 可切换独立 GPU 面板。
如果 NVIDIA 读数消失，请检查 `nvidia-smi` 和内核 Xid 消息；若报告需要
GPU 重置，必须先恢复驱动或 GPU，监控工具才能再次显示传感器数据。

现有 Niri 截图快捷键通过 DMS 的 `DMS_SCREENSHOT_EDITOR` 启动 Satty。
常见图片类型默认使用 Swayimg。FFmpeg、ImageMagick，以及 GStreamer 命令
和插件可直接在 shell 中使用。TeX Live 使用 medium 方案，并包含 LuaTeX、
XeTeX、参考文献工具和中文集合。

新增字体不会改变现有默认字体。朱雀仿宋在 `home/packages/zhuque-fangsong.nix`
中固定为官方 `v0.212` 技术预览 ZIP。Google 图标字体使用 `material-icons`
与 `material-symbols`。

Ventoy 和编辑器及桌面插件批次暂缓。Bottles、KDiskMark 与 wlr-randr 保留，
本次新增没有移除应用程序。

## Ghost Downloader

Home Manager 从官方 x86_64 AppImage 安装
[Ghost Downloader v4.3.7](https://github.com/XiaoYouChR/Ghost-Downloader-3/releases/tag/v4.3.7)，
SHA-256 固定在 `home/packages/ghost-downloader.nix` 中。软件包为自带的
Python 和 Qt 库提供 FHS 环境，并提供用于媒体下载的 FFmpeg。现有 flake
输入保持固定。

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

## WebDAV 挂载与机密

`secrets/webdav.yaml` 中的 WebDAV 用户名和密码由 sops-nix 加密。
私有 age 身份密钥位于 Git 仓库之外：

```text
/home/chomsky/all_files/secrets/sops-nix/age-key.txt
```

已配置的挂载点如下：

```text
~/mnt/infini-cloud-kurio
~/mnt/infini-cloud-higa
```

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

生成的 GTK、qt5ct、qt6ct 与 Kvantum 文件均由 Home Manager 管理。在图形
工具中进行的修改只是临时的；如需持久保存，应将对应设置写回
`home/themes.nix`。

## WPS Office

Home Manager 从稳定版 `wpsoffice-cn` 软件包安装中文个人版，当前固定为
`12.1.2.25882`。文字（`wps`）、表格（`et`）、演示（`wpp`）及 PDF
（`wpspdf`）启动器会显式选择 XWayland 和 Fcitx，以支持 Niri 中的中文
输入。应用菜单入口使用相同的包装启动器；中文显示使用系统已有的
Noto CJK 字体。

WPS 是 Microsoft Word、PowerPoint 和 Excel 文件的默认打开方式，包括
模板及启用宏的文档格式；默认关联同时覆盖标准 MIME 类型和 WPS 自定义
MIME 类型。Google Chrome 继续作为默认浏览器，并默认打开 PDF 文件。

执行 `sudo nixos-rebuild switch --flake .#pisces` 应用配置后，可从应用菜单
或使用 `wps` 启动。

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
`home/packages/readest.nix` 中固定的上游版本构建原生 Nix 软件包，
并使用 `nixpkgs-unstable` 软件包集提供依赖，以避免上游 AppImage 在
Wayland 下的库兼容问题。可通过应用启动器或 `readest` 命令运行。
升级时需更新软件包版本及哈希。

## SylvaKru

[SylvaKru](https://github.com/AfalpHy/sylvakru) 通过
`home/packages/sylvakru.nix` 中固定的官方 x86_64 Linux 版本安装。厂商软件
包已适配 NixOS，并提供 GTK、系统托盘、机密存储、OpenGL 与 mpv 运行库。
它支持本地音乐，以及通过 WebDAV、Navidrome 和 Emby 访问自托管音乐库。
可通过应用启动器或 `sylvakru` 命令运行。

软件包当前固定为 `3.6.0`。升级时需要修改软件包定义中的版本、官方发布
地址及哈希。

## 嵌入式开发

- `esp32-shell` 会从 `~/all_files/projects/dev-envs/esp32` 打开基于 flake
  的 ESP32 开发环境。
- `~/all_files/projects/esp32/.envrc` 会通过 direnv 与 nix-direnv 自动加载
  同一环境。
- STM32 工具包括 STM32CubeMX、Arm 嵌入式工具链、CMake、Ninja、OpenOCD
  及 ST-Link 工具。
- 用户属于 `dialout` 与 `plugdev` 组，并启用 OpenOCD 与 ST-Link udev
  规则；重新登录后即可访问支持的开发板。

## 开源 HDL 与 FPGA 工具

`home/programs.nix` 安装 HDL 工具。Yosys 与 SymbiYosys 一起使用固定的
不稳定版 Nixpkgs 输入，因为稳定版 Yosys 会向新版 Bitwuzla 传递已废弃的
命令行参数；其余工具使用固定的稳定版输入。`system/fpga.nix` 安装
openFPGALoader，并管理 USB/JTAG 访问权限。

| 工具 | 命令 | 用途 |
| --- | --- | --- |
| Icarus Verilog | `iverilog`、`vvp` | Verilog 编译与仿真 |
| Verilator | `verilator` | SystemVerilog 检查与编译式仿真 |
| Verible | `verible-verilog-lint`、`verible-verilog-format`、`verible-verilog-ls` | 检查、格式化与语言服务器 |
| Yosys | `yosys` | RTL 综合与形式化模型生成 |
| nextpnr | `nextpnr-ice40`、`nextpnr-ecp5`、`nextpnr-himbaechel` | FPGA 布局布线 |
| SymbiYosys | `sby` | 基于 Yosys 的形式化验证 |
| Bitwuzla | `bitwuzla` | 形式化验证的 SMT 求解器 |
| openFPGALoader | `openFPGALoader` | FPGA 下载 |

GCC 与 GNU Make 用于编译 Verilator 生成的 C++ 仿真程序。Yices 提供
SymbiYosys 默认使用的 SMT 求解器。若要改用 Bitwuzla，请在项目的 `.sby`
文件中设置：

```ini
[engines]
smtbmc bitwuzla
```

使用 `sby -f design.sby` 运行项目的形式化检查，使用已有的 `surfer` 查看
仿真波形。固定的 nextpnr 软件包包含 iCE40、ECP5 与 Himbaechel 后端，
其中包括 Gowin；Xilinx 后端未启用。Artix-7 的布局布线与位流生成继续
使用下方的 Vivado 环境。openFPGALoader 使用已有的主机端下载器权限。

在普通启动模式下，按下方验证步骤执行
`sudo nixos-rebuild switch --flake .#pisces` 即可应用这些软件包。

## AMD Vitis 与 Vivado 2023.2

Vitis 与 Vivado 在名为 `vitis-2023.2` 的 Ubuntu 22.04 Distrobox 中运行；
NixOS 主机负责 Docker、USB/JTAG 权限、启动命令及 VNC 服务。AMD 工具安装
在与容器共享的 `~/Xilinx` 中，因此重建容器不会删除它们。
`system/fpga.nix` 提供适用于常见 Artix-7 开发板的 AMD/Xilinx 与 Digilent
下载器 udev 规则。

应用系统配置后，请注销并重新登录一次，以获得 `docker` 组成员身份。随后
使用以下命令创建容器、安装依赖并启动 AMD 安装程序：

```bash
vitis-2023.2-setup
```

安装程序应位于
`/home/chomsky/all_files/FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256`。在组件
选择页面保留 **Vitis**、**Vivado**、**Vitis HLS** 与
**Devices for Custom Platforms > 7 Series**。若只使用 Artix-7，请取消
Vitis IP Cache、Vitis Networking P4、Vitis Model Composer、DocNav、Alveo、
Kria、SoCs、UltraScale、UltraScale+、Versal 及工程样片器件。安装目录应设为
`/home/chomsky/Xilinx`；非 root 容器无法写入 `/tools/Xilinx`。无需创建桌面
或程序组快捷方式。

### VNC 桌面与图形界面

安装命令会在 Ubuntu 容器中安装精简的 XFCE 桌面和 TigerVNC。首次使用时
设置一次 VNC 密码：

```bash
distrobox enter --name vitis-2023.2 -- vncpasswd
```

此后 `vitis-vnc.service` 会随 Home Manager 用户会话自动启动，并且只监听
主机回环地址。在 Remmina 中建立指向 `127.0.0.1:5901` 的 VNC 配置即可；
本机连接不需要 SSH 隧道。服务使用隔离的 X11/XFCE 启动环境，以避免继承
NixOS Wayland 会话而导致黑屏或加载不兼容库。

可使用以下命令检查或控制桌面：

```bash
systemctl --user status vitis-vnc.service
systemctl --user restart vitis-vnc.service
systemctl --user stop vitis-vnc.service
journalctl --user -u vitis-vnc.service -f
```

在 VNC 桌面中打开 XFCE Terminal，然后启动相应程序：

```bash
source ~/Xilinx/Vivado/2023.2/settings64.sh
vivado
```

```bash
source ~/Xilinx/Vitis/2023.2/settings64.sh
vitis
```

如果 VNC 服务在设置密码前已经启用，请创建密码后重启服务。VNC 日志位于
`~/.vnc/`。

### 主机端命令行

Vivado 的非图形模式可通过 `vivado-2023.2` Distrobox 包装命令直接从
NixOS 终端运行，无需启动 VNC。该命令会进入 `vitis-2023.2` 容器、加载
`~/Xilinx/Vivado/2023.2/settings64.sh`，并将所有参数原样传给真正的
`vivado` 可执行文件。不要使用 `sudo`。

检查安装、进入 FPGA 项目目录并打开交互式 Tcl shell：

```bash
vivado-2023.2 -version
cd ~/all_files/projects/fpga/my-design
vivado-2023.2 -mode tcl
```

Vivado 默认使用 `gui` 模式，因此从主机运行时应明确选择 `-mode tcl` 或
`-mode batch`。无需打开图形界面即可运行已有 Tcl 构建脚本：

```bash
vivado-2023.2 -mode batch -source build.tcl
vivado-2023.2 -mode batch -source build.tcl -tclargs argument1 argument2
```

NixOS 主目录会以相同路径挂载到 Distrobox，因此可继续在主机上正常编辑项目
文件。Vivado 会在当前目录写入 `vivado.jou` 与 `vivado.log`。若要使用其他
AMD 工具或排查包装命令，可直接进入 Ubuntu：

```bash
distrobox enter --name vitis-2023.2 -- bash
source ~/Xilinx/Vivado/2023.2/settings64.sh
vivado -mode tcl
```

修改本配置后，可通过以下命令应用并重启 VNC：

```bash
sudo nixos-rebuild switch --flake .#pisces
systemctl --user restart vitis-vnc.service
```

## Android 设备修改

`android-tools` 提供 ADB、Fastboot、AVB、启动镜像解包与重新打包、稀疏
镜像转换以及动态分区工具。`payload-dumper-go` 可从 Android OTA 的
`payload.bin` 中提取分区镜像。NixOS 26.05 通过 systemd 内置的 `uaccess`
规则授予 USB 访问权限，因此无需旧的 `adbusers` 用户组或第三方 udev
规则。

应用配置后，在设备上授权 USB 调试，并使用 `adb devices` 检查连接；
进入 bootloader 模式后，使用 `fastboot devices` 检查连接。

## Raspberry Pi 镜像写入

Raspberry Pi Imager 在系统层安装，并配有声明式 PolicyKit 操作；该操作只
匹配 Nix store 中不可变的可执行文件。从应用启动器或终端运行 `rpi-imager`
时，系统会请求管理员认证，再为该次运行提升权限，使其能够写入可移动存储。
不要使用 `sudo` 启动、点击程序中会进行命令式修改的 **Install Authorization**
按钮，也不要通过加入 `disk` 组授予用户不受限制的原始磁盘访问权限。

## 使用 Bottles 运行 Windows 游戏

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

系统还安装了目前维护的上游 7-Zip CLI。`7zz` 与兼容命令 `7z` 均可使用，
两者都会调用固定 Nixpkgs 软件包集中的 `26.02` 版本。Fish 提供使用
LZMA2 最高压缩等级的 `7zip` 与 `7sec` 别名，以及按 100 GiB 分卷的
`7zipv` 与 `7secv`。`7sec` 系列使用已配置的便捷口令同时加密文件内容和文件名。

## 虚拟机

`system/virtualization.nix` 会启用 libvirt 与硬件加速的 `qemu_kvm`
软件包，并将 virt-manager 配置为连接 `qemu:///system`。QEMU 客户机以
非特权账户 `qemu-libvirtd` 运行，并为需要 TPM 2.0 的客户机提供软件 TPM
支持；固定版本的 QEMU 软件包已包含 UEFI 固件。

内置的 `default` NAT 网络由 `libvirt-default-network.service` 设置为自动
启动，并在需要时启动；无需手动执行 `virsh net-start` 或
`virsh net-autostart` 命令。

应用配置后，请注销并重新登录（或重启），使 `chomsky` 账户获得新的
`libvirtd` 用户组成员身份。随后可从应用启动器或终端运行 `virt-manager`。
由 libvirt 管理的新虚拟磁盘保存在 `/var/lib/libvirt/images/`。从主目录
选择 ISO 镜像时，如果 virt-manager 发出提示，请允许它为
`qemu-libvirtd` 账户授予所需的目录访问权限。

由于存储池位于 Btrfs 上，其目录会以声明式方式继承 NOCOW（`C`）属性，
从而避免新建虚拟磁盘同时承受 Btrfs 与 qcow2 两层写时复制。已有磁盘文件
不会被转换，并且 NOCOW 文件不使用 Btrfs 数据校验和或压缩。

可使用以下命令检查硬件加速及系统连接：

```bash
test -e /dev/kvm && echo "KVM is available"
virsh --connect qemu:///system list --all
lsattr -d /var/lib/libvirt/images
```

`lsattr` 的输出应包含大写的 `C`；该命令由系统级安装的 `e2fsprogs`
软件包提供。

`virtiofsd` 已注册到 libvirt，可用于在主机与客户机之间共享目录。关闭
客户机后，先在 virt-manager 的 **Memory** 页面启用共享内存，再通过
**Add Hardware > Filesystem** 选择 `virtiofs` 驱动、主机源目录及任意目标
标签。非特权账户 `qemu-libvirtd` 必须能够遍历并访问完整源路径；应使用
专用共享目录或有针对性的 ACL，而不要放宽整个主目录的权限。Linux 客户机
可通过 `mount -t virtiofs TAG MOUNTPOINT` 挂载该标签；Windows 客户机需要
安装 WinFsp 及 virtio-win 介质中的 VirtIO-FS 客户机组件。

Remmina 作为 Windows 11 客户机的图形化 RDP 客户端安装。请先在 Windows
中启用远程桌面，再通过 `virsh net-dhcp-leases default` 获取客户机地址，
并在 Remmina 中为该地址新建 RDP 连接。Windows 账户必须设置密码，并拥有
使用远程桌面的权限。

现有硬件配置已加载 `kvm-amd`，并通过模块选项 `nested=0` 禁止 Taurus 等
客户机运行嵌套虚拟机。请确保固件设置中的 CPU 虚拟化（SVM）仍处于启用
状态；NixOS 主机仍需要它来提供 `/dev/kvm`。可通过
`cat /sys/module/kvm_amd/parameters/nested` 检查主机设置，输出应为 `0`。

### RTX 4060 直通

`system/vfio.nix` 会新增 `vfio` specialisation，但不会改变正常启动配置。
正常启动项仍由 NixOS 通过 PRIME offload 使用 RTX 4060；`vfio` 启动项则在
initrd 阶段将 IOMMU 组 13 中彼此隔离的两个成员绑定到 `vfio-pci`：

```text
01:00.0  NVIDIA RTX 4060                 10de:28a0
01:00.1  NVIDIA High Definition Audio    10de:22be
```

可使用以下命令安装两个启动项，而不将当前运行的系统切换到 VFIO 模式：

```bash
sudo nixos-rebuild boot --flake .#pisces
```

重启并选择 `vfio` specialisation 后，请检查两个功能是否都显示
`Kernel driver in use: vfio-pci`：

```bash
lspci -nnk -s 01:00.0
lspci -nnk -s 01:00.1
```

完全关闭 Taurus 后，在 virt-manager 中打开其硬件详情，通过
**Add Hardware > PCI Host Device** 添加两个 NVIDIA 功能。请保留 VirtIO
显卡与 SPICE 设备作为应急控制台；之后从虚拟机移除物理设备时，Windows
仍会保留已安装的 NVIDIA 驱动。

在正常启动模式下使用 Taurus 前，请将其关闭，并在 virt-manager 中仅移除
两个 NVIDIA PCI 主机设备。也可以在进入正常模式后、尚未启动 Taurus 时
移除它们。随后 Taurus 会使用现有的 VirtIO/SPICE 显示，而 NixOS 继续使用
RTX 4060。请勿移除单独直通的 `05:00.3` USB 控制器。

笔记本内置屏幕在两种模式下都连接到 AMD iGPU。在 VFIO 模式下，物理
NVIDIA HDMI/DisplayPort 输出归 Windows 使用；未连接外部显示器时可使用
RDP。

## 验证与应用

NixOS 不会自动监视这些文件。每次修改配置后，请先在不执行构建的情况下
检查完整 flake：

```bash
nix flake check --no-build
```

如果修改了 Home Manager 配置，还应构建用户配置而不激活它，以检查头像等
生成资源和激活软件包：

```bash
nix build --no-link .#nixosConfigurations.pisces.config.home-manager.users.chomsky.home.activationPackage
```

在正常启动模式下进行普通的软件包、桌面或服务修改时，可应用完整的 NixOS
与 Home Manager 配置：

```bash
sudo nixos-rebuild switch --flake .#pisces
```

ChatGPT Desktop 版本固定在 `flake.lock` 中。日后如需更新，先以普通用户
运行 `nix flake update codex-desktop-linux`，再执行上述重建命令。
单独运行重建命令只会应用已锁定的版本。

`switch` 会创建新的启动 generation、立即激活正常配置，并重新构建继承该
配置的 `vfio` specialisation。父配置中的修改通常会同时出现在两种模式中；
`system/vfio.nix` 仅覆盖为 RTX 4060 预留设备所需的设置。

修改内核、initrd、VFIO、显卡驱动或引导程序时，请安装新的 generation，
但不要改变当前运行的系统，然后重启：

```bash
sudo nixos-rebuild boot --flake .#pisces
sudo reboot
```

当前系统处于 VFIO 模式时应优先使用 `boot`。重启前请关闭 Taurus；否则直接
执行正常配置的 `switch`，可能会在客户机或 VFIO 仍占用 RTX 4060 时尝试将
它交还给 NVIDIA 驱动。

每次成功重构都会创建一个 generation；systemd-boot 会按照
`boot.loader.systemd-boot.configurationLimit` 的配置保留最多十个
generation。如果新配置损坏，可在启动时选择较旧的 generation 恢复。Git
与系统激活彼此独立：提交不会重构系统，重构也不会提交配置。

## 提交前检查

1. 审阅差异，并确认其中不含明文机密。
2. 执行与修改相符的检查，通常至少运行 `nix flake check --no-build`。
3. 如果架构、路径、服务、工作流程或已记录的行为发生变化，应先更新
   README。
4. 仅在文档与实现一致后提交。
