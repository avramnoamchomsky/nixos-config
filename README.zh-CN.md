# NixOS 配置

[English](README.md) | [简体中文](README.zh-CN.md)

用于 `pisces` 笔记本及 `chomsky` 用户环境的声明式配置。

## 主要特性

- 使用 NixOS flakes，并将 Home Manager 集成到系统重构流程中
- 使用 Niri，并由 Git 完整管理其 KDL 配置
- 使用 Dank Material Shell，管理经过审阅的设置和声明式壁纸
- AMD + NVIDIA 混合显卡
- Fcitx5 与 Rime Ice 输入法
- PipeWire、NetworkManager、蓝牙及 Avahi/mDNS
- Fish 和桌面应用，包括作为默认浏览器的 Google Chrome
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
│   └── secrets.nix
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

## 声明式桌面状态

- Niri 仅读取 `~/.config/niri/config.kdl`，该文件由
  `home/niri/config.kdl` 部署。
- DMS 生成的可选 Niri 配置片段未被使用，并会被自动清理。
- 经过审阅的 DMS 设置保存在 `home/dms/settings.json` 中。
- 指定的 DMS 会话偏好通过声明式方式合并；历史记录、检测到的设备及其他
  易变状态仍可由程序写入。
- `home/wallpapers/` 中的壁纸会被部署到 `~/Pictures/Wallpapers`。
  DMS 根据当前所选壁纸的路径确定壁纸轮换目录。

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
- GTK 4/libadwaita 会保留原生外观。第三方 GTK 4 主题需要 CSS 变通方案，
  可能破坏应用程序样式，因此此处不启用。

生成的 GTK、qt5ct、qt6ct 与 Kvantum 文件均由 Home Manager 管理。在图形
工具中进行的修改只是临时的；如需持久保存，应将对应设置写回
`home/themes.nix`。

## 嵌入式开发

- `esp32-shell` 会从 `~/all_files/projects/dev-envs/esp32` 打开基于 flake
  的 ESP32 开发环境。
- `~/all_files/projects/esp32/.envrc` 会通过 direnv 与 nix-direnv 自动加载
  同一环境。
- STM32 工具包括 STM32CubeMX、Arm 嵌入式工具链、CMake、Ninja、OpenOCD
  及 ST-Link 工具。
- 用户属于 `dialout` 与 `plugdev` 组，并启用 OpenOCD 与 ST-Link udev
  规则；重新登录后即可访问支持的开发板。

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
