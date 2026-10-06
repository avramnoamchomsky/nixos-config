# 运维指南

[English](operations.md) | [简体中文](operations.zh-CN.md) | [README](../README.zh-CN.md)

本流程适用于 `pisces` 与 `chomsky`。在仓库根目录执行 Nix 命令。
Shell 示例使用 Bash；不含 Bash 特有语法的命令也可在配置的 Fish 中运行。

## 目录

- [验证与应用](#验证与应用)
- [更新固定输入与软件包](#更新固定输入与软件包)
- [启动签名与恢复](#启动签名与恢复)
- [混合显卡与监控](#混合显卡与监控)
- [电源管理](#电源管理)
- [MSI 控制与触控板](#msi-控制与触控板)
- [机密与 WebDAV](#机密与-webdav)
- [网络与主机服务](#网络与主机服务)
- [虚拟机](#虚拟机)与 [RTX 4060 直通](#rtx-4060-直通)

## 验证与应用

Home Manager 已集成到 `nixosConfigurations.pisces`，系统重构也会构建并激活
`chomsky` 用户环境。`system.stateVersion` 与 `home.stateVersion` 均为 `26.05`，
用于兼容性设置；修改它们并不是更新输入的步骤。

1. 使用 `git status --short` 与 `git diff` 检查工作区。将新增 Nix 源文件与资源
   加入 Git 暂存区，使 Git flake 可以读取它们。
2. 不更新 lockfile，先求值 flake：

   ```bash
   nix flake check --no-build --no-update-lock-file
   ```

3. 构建完整系统，但不激活：

   ```bash
   nix build --no-link --no-update-lock-file .#nixosConfigurations.pisces.config.system.build.toplevel
   ```

   如需单独验证 Home Manager，可改为构建其激活包：

   ```bash
   nix build --no-link --no-update-lock-file .#nixosConfigurations.pisces.config.home-manager.users.chomsky.home.activationPackage
   ```

flake 检查会求值输出，并不编译软件包或执行激活钩子。成功构建表明请求的输出
可以生成；服务、硬件及应用行为仍需在激活后验证。`--no-link` 避免生成本地
`result` 符号链接。

根据修改内容与当前启动模式选择激活方式：

| 情况 | 命令 | 效果 |
| --- | --- | --- |
| 正常模式下修改普通软件包、桌面或服务 | `sudo nixos-rebuild switch --flake .#pisces` | 安装 generation，立即激活正常系统与 Home Manager |
| 修改内核、initrd、显卡驱动、VFIO 或引导程序 | `sudo nixos-rebuild boot --flake .#pisces` | 安装下次启动 generation，重启后生效 |
| 当前处于 VFIO 模式 | `sudo nixos-rebuild boot --flake .#pisces` | 在受控重启前保持当前 GPU 归属 |

重启前先关闭客户机，然后执行 `sudo reboot`。在 VFIO 或客户机占用 RTX 4060 时
执行正常配置的 `switch`，可能尝试把设备交还给 NVIDIA。两种方式都会构建继承的
`vfio` specialisation；父配置修改会应用到两种模式，但 `system/vfio.nix` 的覆盖
设置除外。

切换后检查相关服务，例如：

```bash
systemctl status home-manager-chomsky.service
systemctl --user status dms.service
journalctl -b -u home-manager-chomsky.service
```

修改 `docker`、`libvirtd`、`wireshark`、`dialout` 或 `plugdev` 组成员身份后，请
注销并重新登录，或重启。成功重构不会更新现有桌面会话的用户组。

## 更新固定输入与软件包

`flake.lock` 固定各输入 revision。稳定版 Nixpkgs 与 Home Manager 使用 26.05
分支；指定应用通过 `unstablePkgs` 使用 `nixpkgs-unstable`。更新该输入不会把
整个系统迁移到 unstable。其他输入提供 nix-flatpak、sops-nix、Lanzaboote 及
`codex-desktop-linux` 桌面集成。

以普通用户更新指定输入，检查 lockfile 差异，然后验证并重构。例如：

```bash
nix flake update codex-desktop-linux
git diff -- flake.lock
```

将输入名替换为 `nixpkgs-unstable` 可更新指定的不稳定版软件包。
`system/hybrid-graphics.nix` 中的驱动版本与哈希、`home/packages/` 中的自定义
软件包及 `home/themes.nix` 中的主题 revision 是额外的固定项。升级时需同步
版本、源地址或 revision 及所有受影响哈希。Readest 分别固定源文件、Cargo、
前端及插件依赖哈希。只执行重构不会更新这些固定项。

Bottles 使用声明的 Flatpak 每周更新器；Vitis 容器中的 Ubuntu 软件包使用 apt。
这些更新独立于 Nix generation。

## 启动签名与恢复

`system/default.nix` 使用 Lanzaboote `v1.1.0` 安装 systemd-boot 与统一内核镜像。
签名密钥在本机 `/var/lib/sbctl` 下生成；`allowUnsigned = true` 允许密钥生成前
的首次重构。`fwupd-efi` 服务等待 `generate-sb-keys.service`。

本配置生成签名密钥，但不会将其注册到固件或启用 Secure Boot。依赖启动签名
强制验证前，请另行检查固件状态，并在 Git 之外备份本机密钥。

systemd-boot 最多保留十个已配置 generation。新 generation 启动失败时，可在
启动菜单选择仍保留的旧 generation。这会恢复其 NixOS 配置，不会回退 Git、应用
数据、Flatpak 更新、容器软件包或虚拟机磁盘。

Nix 每周自动执行带 `--delete-older-than 7d` 的垃圾回收，因此旧 profile
generation 可能被清理；十个启动项的上限并不保证永久保留十个可恢复系统。
Nix 还自动优化 store。缓存顺序为 SJTUG、中科大，再到官方 NixOS 缓存。

## 混合显卡与监控

固件应使用 Hybrid/MSHybrid 显卡模式。正常启动使用 `05:00.0` 的 AMD Raphael
显卡驱动内置屏幕，并将渲染任务通过 PRIME offload 交给 `01:00.0` 的 RTX 4060。
已启用 NVIDIA 开源内核模块、modesetting、Dynamic Boost 及细粒度电源管理。
驱动显式固定为 `610.57.04`；内核来自已固定稳定版输入的 `linuxPackages_latest`。

使用主机 offload 包装命令运行需要 GPU 的应用：

```bash
nvidia-offload vulkaninfo
nvidia-smi
```

`amdgpu.dcdebugmask=0x40000` 参数修改自定义背光映射，用于已记录的 97–98%
附近亮度问题。VFIO 启动使用 AMD 主机驱动，将 NVIDIA 图形与音频功能预留给客户机。

btop 构建时启用 NVIDIA NVML 与 AMD ROCm SMI；其 ROCm 依赖使用打包的 PCI
数据库，将核显识别为 Raphael。NVTOP 使用 NVML 头文件，无需完整 CUDA 工具链。
在 btop 中，`5` 与 `6` 切换各 GPU 面板。

正常模式下读数失败时，检查驱动与内核日志：

```bash
nvidia-smi --query-gpu=name,gpu_recovery_action,temperature.gpu,utilization.gpu,clocks.gr --format=csv
journalctl -b -k --grep='NVRM|Xid'
btop
nvtop
```

[2026-10-05 审计后续记录](software-audit-2026-10-04.md#gpu-monitoring-follow-up--2026-10-05)
记录了 Xid 119/GSP RPC 超时后 NVIDIA 需要重置的状态。该记录属于历史信息，
不能说明 GPU 当前状态。驱动报告需要重置时，先保存工作、关闭客户机并重启，
然后再检查。记录中的后续方案是在重启无法恢复时完全关机再开机。
Niri 持有 GPU 句柄时，在线重置可能中断桌面。部分 AMD 传感器字段即使设备
识别正常也不受支持。设备属于 VFIO 时，主机无法读取 NVIDIA 遥测。

## 电源管理

`system/power-management.nix` 通过 systemd 禁用挂起、休眠、混合睡眠及“先挂起后休眠”。
目前不再计划启用休眠，AMD 平台恢复问题也尚未解决。合盖动作被设置为
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

已跟踪的 DMS 设置还将自动锁屏与挂起超时设为零。请使用 `Super+Alt+L` 手动
锁屏；关闭显示器与系统睡眠是不同操作。

## MSI 控制与触控板

`system/msi-control.nix` 为 MControlCenter 加载 `msi-ec` 与 `ec_sys`。
本机 EC `17KKIMS1.115` 使用已测试的 `17KKIMS1.114` 驱动布局，并启用
`ec_sys` 写入支持以设置自定义风扇曲线。`home/desktop.nix` 声明平衡模式及
两个风扇曲线，不将窗口位置尺寸写入 Git。持久硬件偏好应通过该模块重新应用。

`system/default.nix` 为标识为 `05ac:0265` 的外接触控板在 `hid_magicmouse`
之前加载 `hid_multitouch`，其第二个 HID 接口需要多点触控支持。
这些设置针对本笔记本及该外设。

## 机密与 WebDAV

`secrets/webdav.yaml` 保存加密 WebDAV 用户名与密码；`.sops.yaml` 声明公开的
age 接收者。`system/secrets.nix` 需要仓库之外的私有身份密钥：

```text
/home/chomsky/all_files/secrets/sops-nix/age-key.txt
```

新安装激活前请恢复该身份密钥，仅允许其所有者读取，并在 Git 之外备份。
不要把私有身份或解密凭据放入 Nix 表达式或提交。可在仓库根目录编辑加密文件：

```bash
SOPS_AGE_KEY_FILE=/home/chomsky/all_files/secrets/sops-nix/age-key.txt nix shell --inputs-from . --no-update-lock-file nixpkgs#sops -c sops secrets/webdav.yaml
```

`--inputs-from .` 从本 flake 固定的 Nixpkgs 输入选择 sops。sops-nix 在 `/run/secrets/rclone/`
下解密四项机密，所有者为 `chomsky`，权限为 `0400`。`home/rclone.nix` 读取
这些路径。Home Manager 将机密值直接写入 rclone 配置，不进行转换。更换密码时，
应将 `rclone obscure` 的输出写入加密 YAML 密码字段；用户名使用普通值。
两者都应通过 sops 保持加密。

`home/rclone.nix` 配置以下挂载：

| 远程 | WebDAV 地址 | 挂载点 |
| --- | --- | --- |
| `infini-cloud-kurio` | `https://kurio.infini-cloud.net/dav/` | `~/mnt/infini-cloud-kurio` |
| `infini-cloud-higa` | `https://higa.teracloud.jp/dav/` | `~/mnt/infini-cloud-higa` |

两个挂载都在 `~/.cache/rclone/<remote>` 使用 full VFS 缓存，目标大小 `10Gi`、
最长保留 24 小时、写回延迟五秒、目录缓存五分钟，并关闭轮询。`077` umask
将访问限制为当前用户。本地写入可能仍等待远程上传，停止有待上传数据的挂载前
请检查日志。

检查用户配置服务与两个挂载服务：

```bash
systemctl --user status rclone-config.service
systemctl --user status 'rclone-mount:@infini-cloud-kurio.service'
systemctl --user status 'rclone-mount:@infini-cloud-higa.service'
journalctl --user -b -u 'rclone-mount:@infini-cloud-kurio.service'
```

激活及正常挂载需要 age 身份与远程账户；克隆仓库不会提供它们。

## 网络与主机服务

NetworkManager 管理主机连接。Avahi 发布 `pisces.local`、工作站与地址记录，并
解析 IPv4 `.local` 名称。蓝牙、UPower、fwupd、fstrim、PipeWire、GNOME keyring、
GVfs 与 UDisks 均已启用；Home Manager 的 udiskie 服务为 Niri 提供可移动存储自动挂载。

OpenSSH 允许 `chomsky` 使用密码认证，关闭 root 登录与键盘交互式认证，并以声明式
方式开放防火墙。LocalSend 开放 TCP/UDP `53317`；Avahi 开放对应服务端口。
Docker 使用系统守护进程，并通过 `docker` 组授权访问。

专用 `enp3s0` FPGA 连接受到防火墙信任，使用静态且不提供默认路由的网络。
请将它连接到预期的隔离开发板网络。[FPGA 网络指南](development.zh-CN.md#fpga-网络与-tftp)
说明了地址、只读 TFTP 服务及检查流程。Vitis VNC 仅监听回环地址。

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
中启用远程桌面，再通过 `virsh --connect qemu:///system net-dhcp-leases default` 获取客户机地址，
并在 Remmina 中为该地址新建 RDP 连接。Windows 账户必须设置密码，并拥有
使用远程桌面的权限。

现有硬件配置已加载 `kvm-amd`，并通过模块选项 `nested=0` 禁止 Taurus 等
客户机运行嵌套虚拟机。请确保固件设置中的 CPU 虚拟化（SVM）仍处于启用
状态；NixOS 主机仍需要它来提供 `/dev/kvm`。可通过
`cat /sys/module/kvm_amd/parameters/nested` 检查主机设置，输出应为 `0`。

### RTX 4060 直通

`system/vfio.nix` 会新增 `vfio` specialisation，但不会改变正常启动配置。
正常启动项仍由 NixOS 通过 PRIME offload 使用 RTX 4060；`vfio` 启动项则在
initrd 阶段将两个 NVIDIA 功能绑定到 `vfio-pci`：

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

分配设备前请检查当前 IOMMU 分组。之前的本机设置记录为组 13，但固件或硬件
变化可能改变分组。Taurus 是已有 Windows 客户机；其 domain、磁盘及 PCI 分配
属于本地 libvirt 状态，并不由此 flake 创建。

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
