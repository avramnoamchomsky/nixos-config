# Pisces NixOS 配置

[English](README.md) | [简体中文](README.zh-CN.md)

用于 `Pisces` MSI Alpha 17 C7VF 笔记本及 `chomsky` 账户的个人 NixOS 配置。
一次 flake 重建同时管理系统与 Home Manager。硬件标识、文件系统 UUID、用户路径
及外部开发环境均针对本机设置。

## 配置概览

| 项目 | 配置 |
| --- | --- |
| 平台 | `x86_64-linux`；NixOS 与 Home Manager 26.05；时区 `Asia/Shanghai` |
| 软件包来源 | 系统使用稳定版 Nixpkgs，部分应用和工具使用独立且固定的 unstable 输入 |
| 内核与显卡 | 固定稳定版输入中的 `linuxPackages_latest`，以及显式固定的 NVIDIA 驱动 |
| 桌面 | 在 `tty1` 控制台登录后启动 Niri，配合 Dux Modular Shell（DMS）、Ghostty、Nautilus 与 XWayland |
| 输入与音频 | Fcitx5（MSIME）及 PipeWire/WirePlumber |
| 外观 | 声明式 MacTahoe GTK/Kvantum 主题、Wood Whale 头像及壁纸集合 |
| 存储 | LUKS 加密 Btrfs、zram、可移动存储自动挂载及两个 rclone WebDAV 挂载 |
| 虚拟化 | libvirt/KVM、virt-manager、Docker/Distrobox 及 RTX 4060 `vfio` 启动 specialisation |
| 开发 | ESP32/STM32、Linux 交叉编译器与 QEMU 固件、HDL/形式化工具及 Ubuntu 22.04 Vitis/Vivado 2023.2 |
| 应用 | Chrome、WPS Office、Ghost Downloader、百度网盘、115 生活/浏览器、Readest、SylvaKru、创作工具、Steam 及 Flatpak Bottles |

**挂起与休眠已禁用，合上屏幕不会让机器进入睡眠。** 本机记录的 AMD 平台恢复问题
尚未解决，详见[电源管理](docs/operations.zh-CN.md#电源管理)。

## 验证与应用

在已配置机器的仓库根目录执行以下命令；NixOS 需要启用 Nix 命令与 flakes。
首次激活前，请恢复[机密与 WebDAV](docs/operations.zh-CN.md#机密与-webdav)中说明的
本机 age 身份密钥。

```bash
cd ~/all_files/projects/nixos-config
nix flake check --no-build --no-update-lock-file
nix build --no-link --no-update-lock-file .#nixosConfigurations.Pisces.config.system.build.toplevel
```

在正常启动模式下修改普通桌面、软件包或服务后，同时应用系统与 Home Manager：

```bash
sudo nixos-rebuild switch --flake .#Pisces
```

修改内核、initrd、显卡驱动、VFIO 或引导程序时，请使用
`sudo nixos-rebuild boot --flake .#Pisces`，关闭客户机后重启。当前处于 VFIO
specialisation 时也应使用 `boot`。完整的验证、激活、输入更新及恢复流程见
[运维指南](docs/operations.zh-CN.md#验证与应用)。

提交文件不会激活配置，修改文件也不会自动触发 NixOS 重建。新增源文件应在本地
Git flake 求值前加入 Git，使 Nix 包含它们。

## 文档导航

| 指南 | 内容 |
| --- | --- |
| [架构](docs/architecture.zh-CN.md) / [Architecture](docs/architecture.md) | 配置加载顺序、文件归属及如何添加主机或账户 |
| [运维](docs/operations.zh-CN.md) / [Operations](docs/operations.md) | 构建与激活、启动签名、混合显卡、电源策略、机密、网络、虚拟机及 VFIO |
| [桌面](docs/desktop.zh-CN.md) / [Desktop](docs/desktop.md) | DMS 与 Niri 配置归属、截图、Shell、模糊效果、插件及应用 |
| [开发](docs/development.zh-CN.md) / [Development](docs/development.md) | 嵌入式与 HDL 工具、FPGA TFTP 网络、Vitis/Vivado 安装与 VNC、Android 工具、镜像写入及中文 TeX |
| [软件审计 — 2026-10-04](docs/software-audit-2026-10-04.md) | 历史软件清单、安装决策、验证记录及 2026-10-05 GPU 监控后续记录（英文） |

指南描述当前声明式配置。带日期的审计记录描述该次安装时的观察结果，其中的
generation 编号、本地应用状态、传感器读数及剩余磁盘空间均为历史记录。

## 仓库索引

仓库根目录的 flake 固定共享输入。每台主机显式导入所需的系统模块，并在主机自己的
账户配置中选择 Home Manager 模块。不同主机上的同名账户可以使用不同的组、Shell
和应用。模块关系以及如何添加主机或账户，详见[架构指南](docs/architecture.zh-CN.md)。

| 路径 | 职责 |
| --- | --- |
| [flake.nix](flake.nix)、[flake.lock](flake.lock) | 共享输入、可复现版本及主机入口 |
| [hosts/Pisces](hosts/Pisces) | 硬件与存储、启动、网络、VFIO 及系统模块选择 |
| [hosts/Pisces/users/chomsky.nix](hosts/Pisces/users/chomsky.nix) | Unix 账户、权限组、登录 Shell 及 Home Manager 配置 |
| [hosts/Pisces/assets](hosts/Pisces/assets) | Pisces 的壁纸与账户头像 |
| [hosts/Pisces/webdav.nix](hosts/Pisces/webdav.nix)、[secrets/webdav.yaml](secrets/webdav.yaml) | 用户挂载、GVfs 可见性及加密凭据 |
| [system/](system) | 可选的 NixOS 桌面服务、游戏及嵌入式开发模块 |
| [home/](home) | 可选的 Home Manager 应用、Shell、主题及 Niri 模块 |
| [packages/](packages)、[scripts/](scripts) | 本地软件包定义及 OpenAI 桌面更新脚本 |

## 修改与提交

修改对应源模块或资源，验证相关输出，并同步受影响指南的两种语言版本。
提交前检查 `git diff --check` 和完整差异；解密凭据、私钥、应用历史及生成构建文件
应保留在 Git 之外。配置修改通常至少需要上述 flake 检查及相关输出的构建；
仅文档修改需要检查链接、命令与配置一致性。

仓库配置采用 [MIT 许可证](LICENSE)，打包应用及第三方资源保留各自的许可证。
