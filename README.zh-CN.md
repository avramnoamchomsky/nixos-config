# NixOS 配置

[English](README.md) | [简体中文](README.zh-CN.md)

用于 `pisces` 笔记本及 `chomsky` 用户环境的声明式配置。

## 主要特性

- 使用 NixOS flakes，并将 Home Manager 集成到系统重构流程中
- 使用 `linuxPackages_latest`，当前固定为 Linux `7.1.8`
- 使用 Niri，并由 Git 完整管理其 KDL 配置
- 使用 Dank Material Shell，管理经过审阅的设置和声明式壁纸
- AMD + NVIDIA 混合显卡
- 显式配置的 s2idle 挂起及由加密 Btrfs 支持的休眠
- Fcitx5 与 Rime Ice 输入法
- PipeWire、NetworkManager、蓝牙及 Avahi/mDNS
- 由 libvirt 与 virt-manager 管理的 KVM/QEMU 虚拟化环境
- 通过 UDisks 与 udiskie 自动挂载可移动存储设备
- Fish 和桌面应用，包括 Remmina、SylvaKru、Readest、115 浏览器及作为默认浏览器的 Google Chrome
- 声明式 MacTahoe GTK 与 Kvantum 主题，以及 nwg-look、qt5ct 和 qt6ct
- ESP32 与 STM32 开发工具、direnv 及硬件访问规则
- 使用 sops-nix 加密机密，并由仅存在于本机的 age 身份密钥解密
- 自动挂载两个 InfiniCLOUD WebDAV 账户及可选的局域网主机 `aquarius.local`

## 目录结构

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
│   ├── power-management.nix
│   ├── secrets.nix
│   └── virtualization.nix
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
│   ├── packages
│   │   ├── 115-browser.nix
│   │   └── sylvakru.nix
│   ├── programs.nix
│   ├── rclone.nix
│   ├── themes.nix
│   └── wallpapers
│       └── ...
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

`system/power-management.nix` 仅启用 s2idle 挂起和 S4 休眠，并禁用混合
睡眠及“先挂起后休眠”。DMS 电源菜单会提供这两个已启用的模式。

日常内存压力仍由 zram 处理。休眠则使用 72 GiB 的
`/var/lib/swapfile`；NixOS 会使用兼容 Btrfs 的 NOCOW 属性创建该文件。
该文件位于 LUKS 加密的根文件系统内，因此保存到磁盘的内存映像也会加密。

基于 systemd 的 initrd 会通过 EFI `HibernateLocation` 元数据动态查找交换
文件及其 Btrfs 偏移量，无需写死 `resume_offset`。应用配置后，请在首次
测试前重启一次，然后执行以下命令验证支持状态：

```bash
swapon --show
busctl call org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager CanHibernate
```

第二条命令应返回 `s "yes"`。请保存所有工作后再测试休眠。如果删除
`/var/lib/swapfile`，下次重新构建时会自动创建它。

## 声明式桌面状态

- Niri 仅读取 `~/.config/niri/config.kdl`，该文件由
  `home/niri/config.kdl` 部署。
- DMS 生成的可选 Niri 配置片段未被使用，并会被自动清理。
- 经过审阅的 DMS 设置保存在 `home/dms/settings.json` 中。
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
~/mnt/aquarius
```

允许 `aquarius.local` 处于离线状态。其用户服务会每隔 30 秒重新尝试启动，
且不会阻塞系统启动。目前该连接使用未加密的 HTTP；如果服务器将来支持
HTTPS，应优先改用 HTTPS。

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

## 115 浏览器

[官方 x86_64 Linux 版](https://q.115.com/115/T888199.html) 115 浏览器在
`home/packages/115-browser.nix` 中以声明式方式打包。版本 `35.30.0` 及下载
哈希已固定，厂商二进制文件已适配 NixOS，并会在 Niri 下启用 Wayland
输入法支持。可通过应用启动器或 `115-browser` 命令运行。

该厂商版本报告其 Chromium 版本为 `125.0.6422.61`，版本较旧。建议仅用于
115 专属功能；日常网页浏览仍使用默认的 Google Chrome。

浏览器无法更新 Nix store 中的只读文件。升级时需要修改软件包定义中的
版本、官方下载地址及哈希，然后重新构建系统。

## Readest

[Readest](https://github.com/readest/readest) 从 `nixpkgs-unstable` 软件包集
安装，以获得较新的原生 Nix 构建，并避免上游 AppImage 在 Wayland 下的
库兼容问题。可通过应用启动器或 `readest` 命令运行；更新 flake 的
unstable 输入时，其版本也会随之升级。

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

现有硬件配置已加载 `kvm-amd`，并通过模块选项 `nested=1` 为 Taurus 等使用
host-passthrough 的客户机显式启用嵌套虚拟化。请确保固件设置中的 CPU
虚拟化（SVM）处于启用状态；如果 SVM 被禁用，系统将无法提供 `/dev/kvm`。
可通过 `cat /sys/module/kvm_amd/parameters/nested` 检查主机设置，输出应为
`1`。

## 验证与应用

在不执行构建的情况下检查完整 flake：

```bash
nix flake check --no-build
```

应用完整的 NixOS 与 Home Manager 配置：

```bash
sudo nixos-rebuild switch --flake .#pisces
```

## 提交前检查

1. 审阅差异，并确认其中不含明文机密。
2. 执行与修改相符的检查，通常至少运行 `nix flake check --no-build`。
3. 如果架构、路径、服务、工作流程或已记录的行为发生变化，应先更新
   README。
4. 仅在文档与实现一致后提交。
