# Development guide

[English](development.md) | [简体中文](development.zh-CN.md) | [README](../README.md)

The host declares development tools, device permissions, and launch wrappers.
Project sources, the external ESP32 flake, the AMD installer, installed AMD
tools, and container contents live outside this repository. Apply host changes
through [Validate and apply](operations.md#validate-and-apply).

## Contents

- [Embedded development](#embedded-development)
- [Open-source HDL and FPGA tools](#open-source-hdl-and-fpga-tools)
- [FPGA network and TFTP](#fpga-network-and-tftp)
- [AMD Vitis and Vivado 2023.2](#amd-vitis-and-vivado-20232)
- [VNC desktop and GUI tools](#vnc-desktop-and-gui-tools)
- [Host-side CLI](#host-side-cli)
- [Android device tools](#android-device-tools)
- [Raspberry Pi imaging](#raspberry-pi-imaging)
- [Chinese TeX](#chinese-tex)

## Embedded development

- `esp32-shell` opens the flake-based ESP32 environment from
  `~/all_files/projects/dev-envs/esp32`.
- `~/all_files/projects/esp32/.envrc` automatically loads the same environment
  through direnv and nix-direnv.
- STM32 tools include STM32CubeMX, the Arm embedded toolchain, CMake, Ninja,
  OpenOCD, and ST-Link utilities.
- Membership in `dialout` and `plugdev`, plus the OpenOCD and ST-Link udev
  rules, grants access to supported development boards after a fresh login.

The ESP32 development flake must already exist at that external path. For
direnv, review the project `.envrc` and run `direnv allow` in
`~/all_files/projects/esp32` after creating the project directory. Home Manager
declares `.envrc`; it does not supply the SDK flake or project sources.

## Open-source HDL and FPGA tools

`home/programs.nix` installs the HDL tools. Yosys and SymbiYosys use the pinned
unstable Nixpkgs input together because stable Yosys passes obsolete CLI flags
to modern Bitwuzla; the remaining tools use the pinned stable input.
`system/fpga.nix` installs openFPGALoader and manages USB/JTAG access.

| Tool | Command | Purpose |
| --- | --- | --- |
| Icarus Verilog | `iverilog`, `vvp` | Verilog compilation and simulation |
| Verilator | `verilator` | SystemVerilog linting and compiled simulation |
| Verible | `verible-verilog-lint`, `verible-verilog-format`, `verible-verilog-ls` | Linting, formatting, and language server |
| Yosys | `yosys` | RTL synthesis and formal model preparation |
| nextpnr | `nextpnr-ice40`, `nextpnr-ecp5`, `nextpnr-himbaechel` | FPGA placement and routing |
| SymbiYosys | `sby` | Yosys-based formal verification |
| Bitwuzla | `bitwuzla` | SMT solving for formal verification |
| openFPGALoader | `openFPGALoader` | FPGA programming |

GCC and GNU Make are included for building Verilator's generated C++
simulations. Yices supplies SymbiYosys's default SMT solver. To select Bitwuzla
instead, use this engine section in a project's `.sby` file:

```ini
[engines]
smtbmc bitwuzla
```

Run a project's formal checks with `sby -f design.sby` and inspect simulation
waveforms with the existing `surfer` viewer. The pinned nextpnr package includes
iCE40, ECP5, and Himbaechel backends, including Gowin; its Xilinx backend is
disabled. Artix-7 placement, routing, and bitstream generation continue to use
the Vivado environment below. openFPGALoader uses the existing host-side
programmer permissions.

## FPGA network and TFTP

`system/fpga.nix` declares a NetworkManager profile named `fpga-tftp` on
`enp3s0`, with host address `10.90.50.43/24`. It autoconnects, has no gateway or
DNS, disables IPv6, and never supplies the default route. Wi-Fi retains its
normal route. The board must use a compatible address on the same subnet.

atftpd binds only to `10.90.50.43` and serves `/srv/tftp`. Nix fetches and pins
the Loongson educational LA32R Linux `v0.1` and `v0.2` images, exposed as
`vmlinux-v0.1` and `vmlinux-v0.2`. The service sees its root as read-only, so
TFTP uploads cannot replace the images. It waits for the static address before
binding and restarts after failures.

The firewall trusts the whole `enp3s0` interface to permit TFTP's dynamic
transfer ports. Use this physical link for the dedicated isolated FPGA
connection. The `atftp` client is also on the user PATH.

```bash
nmcli connection show fpga-tftp
ip -4 address show dev enp3s0
ip route
systemctl status atftpd.service
journalctl -b -u atftpd.service
ls -l /srv/tftp/vmlinux-v0.1 /srv/tftp/vmlinux-v0.2
```

Expect `10.90.50.43/24` on `enp3s0`, no default route through that interface,
and the two image links pointing into the Nix store. A startup address timeout
calls for checking the interface name, profile activation, and link state.

## AMD Vitis and Vivado 2023.2

Vitis and Vivado run in an Ubuntu 22.04 Distrobox named `vitis-2023.2` while
the NixOS host owns Docker, USB/JTAG permissions, launch commands, and the VNC
service. The AMD tools are installed under `~/Xilinx`, which is shared with the
container and remains intact if the container is recreated. `system/fpga.nix`
provides udev rules for AMD/Xilinx and Digilent programmers commonly used with
Artix-7 boards.

After rebuilding, log out and back in once to acquire membership in the
`docker` group. Create the container, install its dependencies, and start the
AMD installer with:

```bash
vitis-2023.2-setup
```

The installer is expected at
`/home/chomsky/all_files/FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256`. On its
component-selection page, keep **Vitis**, **Vivado**, **Vitis HLS**, and
**Devices for Custom Platforms > 7 Series**. For an Artix-7-only installation,
disable Vitis IP Cache, Vitis Networking P4, Vitis Model Composer, DocNav,
Alveo and Kria platforms, SoCs, UltraScale, UltraScale+, Versal, and engineering
sample devices. Set the destination to `/home/chomsky/Xilinx`; `/tools/Xilinx`
is not writable by the normal user inside the container. Desktop and
program-group shortcuts are unnecessary.

### VNC desktop and GUI tools

The setup command installs a minimal XFCE desktop and TigerVNC in the Ubuntu
container. Set the VNC password once:

```bash
distrobox enter --name vitis-2023.2 -- vncpasswd
```

`vitis-vnc.service` starts with the Home Manager user session once
`~/.vnc/passwd` exists. After creating the password in an already running
session, run `systemctl --user restart vitis-vnc.service` to start or restart
it. It listens only on the host loopback interface. Create a Remmina VNC
profile pointing to `127.0.0.1:5901`; no SSH tunnel is required for a local
connection. The service uses an isolated X11/XFCE startup environment to avoid
the black-screen and incompatible-library problems caused by inheriting the
NixOS Wayland session.

Use these commands to inspect or control the desktop:

```bash
systemctl --user status vitis-vnc.service
systemctl --user restart vitis-vnc.service
systemctl --user stop vitis-vnc.service
journalctl --user -u vitis-vnc.service -f
```

Inside the VNC desktop, open XFCE Terminal and launch either application:

```bash
source ~/Xilinx/Vivado/2023.2/settings64.sh
vivado
```

```bash
source ~/Xilinx/Vitis/2023.2/settings64.sh
vitis
```

If the VNC service was enabled before the password existed, create the password
and restart the service. VNC logs are available under `~/.vnc/`.

### Host-side CLI

Vivado's non-graphical modes work directly from a NixOS terminal through the
`vivado-2023.2` Distrobox wrapper; VNC does not need to be running. The wrapper
enters `vitis-2023.2`, sources `~/Xilinx/Vivado/2023.2/settings64.sh`, and
forwards every argument to the real `vivado` executable. Do not use `sudo`.

Check the installation, change to the FPGA project directory, and open the
interactive Tcl shell with:

```bash
vivado-2023.2 -version
cd ~/all_files/projects/fpga/my-design
vivado-2023.2 -mode tcl
```

The default mode is `gui`, so explicitly use `-mode tcl` or `-mode batch` from
the host. To execute an existing Tcl build script without opening a GUI:

```bash
vivado-2023.2 -mode batch -source build.tcl
vivado-2023.2 -mode batch -source build.tcl -tclargs argument1 argument2
```

Directories under the NixOS home directory are mounted into Distrobox at the
same paths, so project files can be edited normally on the host. Vivado writes
`vivado.jou` and `vivado.log` to the current directory. To use another AMD tool
or diagnose the wrapper, enter Ubuntu directly:

```bash
distrobox enter --name vitis-2023.2 -- bash
source ~/Xilinx/Vivado/2023.2/settings64.sh
vivado -mode tcl
```

After changing `home/vitis.nix`, follow the
[system activation workflow](operations.md#validate-and-apply) and restart `vitis-vnc.service` if the VNC startup configuration changed.

The host enables the system Docker daemon; this is not a rootless Docker
configuration. Run the setup and host wrappers as `chomsky`. The installer,
license acceptance, AMD installation, container packages, and VNC password
remain manual state. Nix recreates the launchers and service, not those files.

## Android device tools

`android-tools` provides ADB, Fastboot, AVB tools, boot-image unpacking and
repacking, sparse-image conversion, and dynamic-partition utilities.
`payload-dumper-go` extracts partition images from Android OTA `payload.bin`
files. NixOS 26.05 grants USB access through systemd's built-in `uaccess`
rules, so no obsolete `adbusers` group or third-party udev rules are needed.

After applying the configuration, authorize USB debugging on the device and
check it with `adb devices`. In bootloader mode, verify the connection with
`fastboot devices`.

## Raspberry Pi imaging

Raspberry Pi Imager is installed system-wide with a declarative PolicyKit
action tied to its immutable Nix store executable. Launching `rpi-imager` from
the application launcher or terminal requests administrator authentication and
then elevates that invocation so it can write removable storage. Do not run it
with `sudo`, click its imperative **Install Authorization** button, or grant the
user unrestricted raw-disk access through the `disk` group.

## Chinese TeX

`home/programs.nix` combines TeX Live's medium scheme with LuaTeX, XeTeX,
extra bibliography packages, and Chinese collections. XeLaTeX, LuaLaTeX, and
Biber are available as host commands.

The software audit verified the static LXGW WenKai font for Chinese documents.
For example, use this in a document compiled with XeLaTeX or LuaLaTeX:

```tex
\documentclass{ctexart}
\setCJKmainfont{LXGW WenKai}
\begin{document}
中文排版示例。
\end{document}
```

Compile a saved `example.tex` with `xelatex example.tex` or
`lualatex example.tex`. The existing Noto CJK variable TTC failed the recorded
TeX checks; it remains available for desktop applications. Other installed
font choices and desktop font settings are listed in the
[desktop guide](desktop.md#applications-and-system-integrations).
