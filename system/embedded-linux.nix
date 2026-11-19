{ pkgs, ... }:

let
  arm64 = pkgs.pkgsCross.aarch64-multiplatform;
  armv7 = pkgs.pkgsCross.armv7l-hf-multiplatform;
  riscv64 = pkgs.pkgsCross.riscv64;

  qemuFirmware = pkgs.runCommand "embedded-linux-qemu-firmware" { } ''
    mkdir -p "$out/share/embedded-linux"
    ln -s ${arm64.ubootQemuAarch64}/u-boot.bin "$out/share/embedded-linux/u-boot-aarch64.bin"
    ln -s ${riscv64.ubootQemuRiscv64Smode}/u-boot.bin "$out/share/embedded-linux/u-boot-riscv64-smode.bin"
    ln -s ${riscv64.opensbi} "$out/share/embedded-linux/opensbi-riscv64"
  '';
in
{
  environment.pathsToLink = [ "/share/embedded-linux" ];

  environment.systemPackages = with pkgs; [
    qemu
    arm64.buildPackages.gcc
    arm64.buildPackages.binutils
    armv7.buildPackages.gcc
    armv7.buildPackages.binutils
    riscv64.buildPackages.gcc
    riscv64.buildPackages.binutils

    bc
    bison
    flex
    pkg-config
    ncurses
    openssl
    elfutils
    pahole
    ubootTools
    genimage
    qemuFirmware
  ];
}
