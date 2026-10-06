# 开发指南

[English](development.md) | [简体中文](development.zh-CN.md) | [README](../README.zh-CN.md)

主机声明开发工具、设备权限及启动包装命令。项目源文件、外部 ESP32 flake、
AMD 安装程序、已安装 AMD 工具及容器内容均位于仓库之外。
请按照[验证与应用](operations.zh-CN.md#验证与应用)应用主机修改。

## 目录

- [嵌入式开发](#嵌入式开发)
- [开源 HDL 与 FPGA 工具](#开源-hdl-与-fpga-工具)
- [FPGA 网络与 TFTP](#fpga-网络与-tftp)
- [AMD Vitis 与 Vivado 2023.2](#amd-vitis-与-vivado-20232)
- [VNC 桌面与图形界面](#vnc-桌面与图形界面)
- [主机端命令行](#主机端命令行)
- [Android 设备工具](#android-设备工具)
- [Raspberry Pi 镜像写入](#raspberry-pi-镜像写入)
- [中文 TeX](#中文-tex)

## 嵌入式开发

- `esp32-shell` 会从 `~/all_files/projects/dev-envs/esp32` 打开基于 flake
  的 ESP32 开发环境。
- `~/all_files/projects/esp32/.envrc` 会通过 direnv 与 nix-direnv 自动加载
  同一环境。
- STM32 工具包括 STM32CubeMX、Arm 嵌入式工具链、CMake、Ninja、OpenOCD
  及 ST-Link 工具。
- 用户属于 `dialout` 与 `plugdev` 组，并启用 OpenOCD 与 ST-Link udev
  规则；重新登录后即可访问支持的开发板。

ESP32 开发 flake 必须已存在于该外部路径。创建项目目录后，在
`~/all_files/projects/esp32` 中审阅 `.envrc` 并执行 `direnv allow`。
Home Manager 声明 `.envrc`，但不提供 SDK flake 或项目源文件。

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

## FPGA 网络与 TFTP

`system/fpga.nix` 在 `enp3s0` 上声明名为 `fpga-tftp` 的 NetworkManager
配置，主机地址为 `10.90.50.43/24`。该配置自动连接，不设置网关或 DNS，关闭
IPv6，也不会提供默认路由。Wi-Fi 保留正常路由；开发板需要使用同一子网中兼容的地址。

atftpd 仅绑定 `10.90.50.43`，服务根目录为 `/srv/tftp`。Nix 下载并固定龙芯教学
LA32R Linux `v0.1` 与 `v0.2` 镜像，以 `vmlinux-v0.1` 和 `vmlinux-v0.2` 提供。
服务中的根目录只读，TFTP 上传不能替换镜像。服务等待静态地址后绑定，失败后重启。

防火墙信任整个 `enp3s0` 接口，以允许 TFTP 动态传输端口。此物理连接应专用于
隔离的 FPGA 网络。用户 PATH 中还提供 `atftp` 客户端。

```bash
nmcli connection show fpga-tftp
ip -4 address show dev enp3s0
ip route
systemctl status atftpd.service
journalctl -b -u atftpd.service
ls -l /srv/tftp/vmlinux-v0.1 /srv/tftp/vmlinux-v0.2
```

预期 `enp3s0` 上有 `10.90.50.43/24`，默认路由不经过该接口，两个镜像链接指向
Nix store。启动时等待地址超时，应检查接口名称、配置激活及物理连接状态。

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
`/home/chomsky/Xilinx`；容器内的普通用户无法写入 `/tools/Xilinx`。无需创建桌面
或程序组快捷方式。

### VNC 桌面与图形界面

安装命令会在 Ubuntu 容器中安装精简的 XFCE 桌面和 TigerVNC。首次使用时
设置一次 VNC 密码：

```bash
distrobox enter --name vitis-2023.2 -- vncpasswd
```

`~/.vnc/passwd` 存在后，`vitis-vnc.service` 会随 Home Manager 用户会话启动。
在已运行会话中创建密码后，执行 `systemctl --user restart vitis-vnc.service`
启动或重启服务。它只监听
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

修改 `home/vitis.nix` 后，遵循[系统激活流程](operations.zh-CN.md#验证与应用)；
VNC 启动配置变化时，再重启 `vitis-vnc.service`。

主机启用的是系统 Docker 守护进程，并非 rootless Docker 配置。安装与主机包装
命令应以 `chomsky` 运行。安装程序、许可证接受、AMD 安装、容器软件包及 VNC
密码仍属于手动状态；Nix 重建启动器与服务，不会重新创建这些文件。

## Android 设备工具

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

## 中文 TeX

`home/programs.nix` 将 TeX Live medium 方案与 LuaTeX、XeTeX、额外参考文献包
及中文集合组合，提供主机命令 XeLaTeX、LuaLaTeX 与 Biber。

软件审计验证了静态 LXGW WenKai 字体的中文排版。可在 XeLaTeX 或 LuaLaTeX
文档中使用以下示例：

```tex
\documentclass{ctexart}
\setCJKmainfont{LXGW WenKai}
\begin{document}
中文排版示例。
\end{document}
```

保存为 `example.tex` 后，通过 `xelatex example.tex` 或 `lualatex example.tex`
编译。已有 Noto CJK 可变 TTC 未通过记录中的 TeX 检查，但仍可用于桌面应用。
其他已安装字体与桌面字体设置见[桌面指南](desktop.zh-CN.md#应用与系统集成)。
