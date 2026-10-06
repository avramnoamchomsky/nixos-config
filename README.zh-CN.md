# Pisces NixOS 配置

[English](README.md) | [简体中文](README.zh-CN.md)

用于 `pisces` MSI Alpha 17 C7VF 笔记本及 `chomsky` 账户的个人 NixOS 配置。
一次 flake 重构同时管理系统与 Home Manager。硬件标识、文件系统 UUID、用户路径
及外部开发环境均针对本机设置。

## 配置概览

| 项目 | 配置 |
| --- | --- |
| 平台 | `x86_64-linux`；NixOS 与 Home Manager 26.05；时区 `Asia/Shanghai` |
| 软件包来源 | 系统使用稳定版 Nixpkgs，部分应用使用独立且固定的 unstable 输入 |
| 内核与显卡 | `linuxPackages_latest`；当前 lockfile 求值结果为 Linux `7.2.6`；NVIDIA 驱动显式固定为 `610.57.04` |
| 桌面 | greetd/tuigreet → Niri，配合 Dank Material Shell（DMS）、Ghostty、Nautilus 与 XWayland |
| 输入与音频 | Fcitx5、Rime Ice 小鹤双拼及 PipeWire/WirePlumber |
| 外观 | 声明式 MacTahoe GTK/Kvantum 主题、Wood Whale 头像及壁纸集合 |
| 存储 | LUKS 加密 Btrfs、zram、可移动存储自动挂载及两个 rclone WebDAV 挂载 |
| 虚拟化 | libvirt/KVM、virt-manager、Docker/Distrobox 及 RTX 4060 `vfio` 启动 specialisation |
| 开发 | ESP32/STM32、HDL/形式化工具及 Ubuntu 22.04 Vitis/Vivado 2023.2 |
| 应用 | Chrome、WPS Office、Ghost Downloader、115 生活/浏览器、Readest、SylvaKru、创作工具、Steam 及 Flatpak Bottles |

以上版本对应 2026-10-06 仓库固定输入的求值结果，并不代表笔记本当前运行的 generation。

**挂起与休眠已禁用，合上屏幕不会让机器进入睡眠。** 本机记录的 AMD 平台恢复问题
尚未解决，详见[电源管理](docs/operations.zh-CN.md#电源管理)。

## 验证与应用

在已配置机器的仓库根目录执行以下命令；NixOS 需要启用 Nix 命令与 flakes。
首次激活前，请恢复[机密与 WebDAV](docs/operations.zh-CN.md#机密与-webdav)中说明的
本机 age 身份密钥。

```bash
cd ~/all_files/projects/nixos-config
nix flake check --no-build --no-update-lock-file
nix build --no-link --no-update-lock-file .#nixosConfigurations.pisces.config.system.build.toplevel
```

在正常启动模式下修改普通桌面、软件包或服务后，同时应用系统与 Home Manager：

```bash
sudo nixos-rebuild switch --flake .#pisces
```

修改内核、initrd、显卡驱动、VFIO 或引导程序时，请使用
`sudo nixos-rebuild boot --flake .#pisces`，关闭客户机后重启。当前处于 VFIO
specialisation 时也应使用 `boot`。完整的验证、激活、输入更新及恢复流程见
[运维指南](docs/operations.zh-CN.md#验证与应用)。

提交文件不会激活配置，修改文件也不会自动触发 NixOS 重构。新增源文件应在本地
Git flake 求值前加入 Git，使 Nix 包含它们。

## 文档导航

| 指南 | 内容 |
| --- | --- |
| [运维](docs/operations.zh-CN.md) / [Operations](docs/operations.md) | 构建与激活、启动签名、混合显卡、电源策略、机密、网络、虚拟机及 VFIO |
| [桌面](docs/desktop.zh-CN.md) / [Desktop](docs/desktop.md) | 配置归属、快捷键、头像、主题、应用、MIME 默认值、抓包权限及游戏 |
| [开发](docs/development.zh-CN.md) / [Development](docs/development.md) | 嵌入式与 HDL 工具、FPGA TFTP 网络、Vitis/Vivado 安装与 VNC、Android 工具、镜像写入及中文 TeX |
| [软件审计 — 2026-10-04](docs/software-audit-2026-10-04.md) | 历史软件清单、安装决策、验证记录及 2026-10-05 GPU 监控后续记录（英文） |

指南描述当前声明式配置。带日期的审计记录描述该次安装时的观察结果，其中的
generation 编号、本地应用状态、传感器读数及剩余磁盘空间均为历史记录。

## 仓库索引

| 路径 | 职责 |
| --- | --- |
| [flake.nix](flake.nix)、[flake.lock](flake.lock) | 输入、可复现版本、`pisces` 输出及 Home Manager 集成 |
| [system/default.nix](system/default.nix)、[system/hardware-configuration.nix](system/hardware-configuration.nix) | 模块导入、身份、启动、Nix 设置、网络、用户及本机存储 |
| [system/desktop.nix](system/desktop.nix)、[system/gaming.nix](system/gaming.nix) | 会话、输入、音频、桌面服务、权限、字体、Flatpak 及 Steam |
| [system/hybrid-graphics.nix](system/hybrid-graphics.nix)、[system/vfio.nix](system/vfio.nix) | NVIDIA 驱动、PRIME offload 及 GPU 预留 specialisation |
| [system/power-management.nix](system/power-management.nix)、[system/msi-control.nix](system/msi-control.nix) | 睡眠策略、zram 及 MSI 嵌入式控制器支持 |
| [system/virtualization.nix](system/virtualization.nix)、[system/fpga.nix](system/fpga.nix) | KVM/libvirt、Docker、下载器访问及 FPGA 网络/TFTP 服务 |
| [system/secrets.nix](system/secrets.nix)、[.sops.yaml](.sops.yaml)、[secrets/webdav.yaml](secrets/webdav.yaml) | 加密 WebDAV 凭据及其解密策略 |
| [home/default.nix](home/default.nix)、[home/programs.nix](home/programs.nix) | 用户模块、XDG 目录、软件包、Fish、命令行工具及开发环境 |
| [home/desktop.nix](home/desktop.nix)、[home/input-method.nix](home/input-method.nix) | MIME 关联、桌面偏好、MControlCenter 及 Fcitx/Rime 状态 |
| [home/niri.nix](home/niri.nix)、[home/niri/config.kdl](home/niri/config.kdl) | 完整 Niri 配置及未使用 DMS 片段的清理 |
| [home/dms.nix](home/dms.nix)、[home/dms/settings.json](home/dms/settings.json)、[home/dms/Wood_Whale.jpg](home/dms/Wood_Whale.jpg) | DMS 设置、会话偏好合并、默认壁纸及生成头像 |
| [home/themes.nix](home/themes.nix)、[home/wallpapers](home/wallpapers) | 固定主题及已跟踪壁纸资源 |
| [home/ghost-downloader.nix](home/ghost-downloader.nix)、[home/115-life.nix](home/115-life.nix)、[home/packages](home/packages) | 自定义应用包、启动器、URI 处理及朱雀仿宋 |
| [home/rclone.nix](home/rclone.nix)、[home/vitis.nix](home/vitis.nix) | 用户挂载、AMD 工具/容器包装命令及 VNC 服务 |

## 修改与提交

修改对应源模块或资源，验证相关输出，并同步受影响指南的两种语言版本。
提交前检查 `git diff --check` 和完整差异；解密凭据、私钥、应用历史及生成构建文件
应保留在 Git 之外。配置修改通常至少需要上述 flake 检查及相关输出的构建；
仅文档修改需要检查链接、命令与配置一致性。

仓库配置采用 [MIT 许可证](LICENSE)，打包应用及第三方资源保留各自的许可证。
