# 仓库架构

[English](architecture.md) | [简体中文](architecture.zh-CN.md) | [README](../README.zh-CN.md)

仓库当前导出 `nixosConfigurations.Pisces`。Pisces 通过 Home Manager 的 NixOS
模块管理 `chomsky` 账户。每台新增主机都可以声明自己的账户，并选择要导入的系统模块和
用户模块。不同主机可以使用相同的用户名，并分别设置权限、应用和偏好。

## 配置加载顺序

```text
flake.nix + flake.lock
└── nixosConfigurations.Pisces
    └── hosts/Pisces/default.nix
        ├── Pisces 硬件、引导、网络和主机服务
        ├── 从 system/ 选择的 NixOS 模块
        └── hosts/Pisces/users/chomsky.nix
            ├── Unix 账户、用户组和 SSH 允许名单
            ├── 从 home/ 选择的 Home Manager 模块
            └── Pisces 专用桌面和开发设置
```

| 修改内容 | 位置 |
| --- | --- |
| 注册主机或更新共享输入 | [flake.nix](../flake.nix) 和 [flake.lock](../flake.lock) |
| 修改主机的存储、GPU、引导、网络或服务 | [hosts/Pisces/](../hosts/Pisces) |
| 修改账户的用户组、登录 Shell、自动启动、Git 身份或模块选择 | [hosts/Pisces/users/chomsky.nix](../hosts/Pisces/users/chomsky.nix) |
| 修改 Pisces 上的头像、壁纸集合或 Vitis 包装器 | [hosts/Pisces/assets/](../hosts/Pisces/assets) 和 [hosts/Pisces/users/](../hosts/Pisces/users) |
| 修改可复用的系统服务或程序 | [system/](../system) |
| 修改可复用的应用设置、Shell 或 Niri 配置片段 | [home/](../home) |
| 修改本地软件包定义 | [packages/](../packages) |
| 修改 WebDAV 挂载定义或加密值 | [hosts/Pisces/webdav.nix](../hosts/Pisces/webdav.nix) 和 [secrets/webdav.yaml](../secrets/webdav.yaml) |

主机向桌面配置传递 DMS 软件包、配套的 Quickshell 软件包和 DMS 源码。Home Manager
使用主机的稳定版软件包集合。Pisces 也向需要从固定 unstable 输入选择软件的用户模块
传递 `unstablePkgs`。主机和账户均显式导入模块，新文件需要被导入才会生效。

## 添加主机

1. 在 `hosts/` 下创建主机目录，添加 `default.nix` 和为该机器生成的硬件配置。设置
   主机名、架构、引导程序、文件系统、网络及 `system.stateVersion`。该版本控制主机
   初次安装时的兼容性默认值。
2. 导入该机器需要的服务。如果图形主机使用现有桌面模块，参考
   [Pisces 主机配置](../hosts/Pisces/default.nix)中的上游 NixOS 模块导入和配套的 DMS、
   Quickshell 软件包。根据新主机的实际硬件选择专用设置。
3. 如需管理用户环境，在该主机导入 Home Manager，再按下文添加和导入账户文件。
4. 参考 `nixosConfigurations.Pisces` 的写法，在 [flake.nix](../flake.nix) 中注册新输出。
   例如，名为 `Lyra` 的主机使用 `nixosConfigurations.Lyra` 和
   `modules = [ ./hosts/Lyra ];`。
5. 暂存新文件，运行 flake 检查并构建新主机的输出，再进行激活。将
   [验证命令](operations.zh-CN.md#验证与应用)中的 `Pisces` 换成新输出名称。

## 添加主机账户

1. 创建 `hosts/<host>/users/<username>.nix`，并从该主机的 `default.nix` 导入。
   定义 `users.users.<username>`，设置该账户所需的 Shell、用户组和 SSH 访问权限。
2. 如需管理该账户的用户环境，定义 `home-manager.users.<username>`，设置初始
   `home.stateVersion` 并显式导入所需模块。集成式 Home Manager 从 Unix 账户
   获取用户名和主目录。
3. 在账户文件或其导入的文件中设置账户专用的启动方式和应用偏好。Pisces 的
   `tty1` 桌面自动启动属于 `chomsky`。Niri 模块也会在首次激活时初始化可写的
   DMS 配置片段，为已有账户启用前可先确认[迁移行为](desktop.zh-CN.md#桌面配置)。
4. 只为需要 WebDAV 的账户授予访问权限。集中定义挂载和机密所有者，并单独恢复
   目标机器所需的 age 身份密钥。详见[机密与 WebDAV](operations.zh-CN.md#机密与-webdav)。

## 选择配置来源

优先使用固定的稳定版 Nixpkgs 软件包，或已有的 NixOS、Home Manager 选项。
QQ、uv、Yosys 与 SymbiYosys 等选定例外使用固定的 unstable 输入。厂商发行包的
集成和需要 NixOS 专用调整的打包逻辑放在 `packages/`。更新软件包或 flake 输入时，
参见[更新固定输入与软件包](operations.zh-CN.md#更新固定输入与软件包)。

Lockfile 记录用于构建 generation 的输入。DMS 偏好、libvirt 虚拟机与磁盘、
Flatpak 更新、凭据和 Vitis 安装各有自己的存储位置和生命周期。Generation 回滚的
覆盖范围见[运维指南](operations.zh-CN.md#启动签名与恢复)。
