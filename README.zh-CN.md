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
