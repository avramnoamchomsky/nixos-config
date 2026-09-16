{ lib, pkgs, ... }:

let
  containerName = "vitis-2023.2";
  installerDirectory = "/home/chomsky/all_files/FPGAs_AdaptiveSoCs_Unified_2023.2_1013_2256";

  vitisSetup = pkgs.writeShellApplication {
    name = "vitis-2023.2-setup";
    runtimeInputs = with pkgs; [
      coreutils
      distrobox
      docker
    ];

    text = ''
      installer_directory=${lib.escapeShellArg installerDirectory}
      container_name=${lib.escapeShellArg containerName}

      if ! docker info >/dev/null 2>&1; then
        echo "Docker is unavailable. Log out and back in after rebuilding NixOS, then retry." >&2
        exit 1
      fi

      if [[ ! -x "$installer_directory/xsetup" ]]; then
        echo "Vivado/Vitis 2023.2 installer not found at $installer_directory." >&2
        exit 1
      fi

      if ! docker container inspect "$container_name" >/dev/null 2>&1; then
        distrobox create \
          --yes \
          --image docker.io/library/ubuntu:22.04 \
          --name "$container_name"
      fi

      distrobox enter --name "$container_name" -- bash -lc '
        set -euo pipefail
        sudo apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common zip
        sudo add-apt-repository -y universe
        cd /tmp
        sudo '"$installer_directory"'/installLibs.sh
      '

      cat <<'EOF'

The AMD installer will now open. Select:
  Product: Vitis
  Device family: Artix-7 only
  Installation directory: /home/chomsky/Xilinx

Review and accept AMD's license agreements in the installer, then start the
installation. The files stay in your home directory and persist independently
of the Distrobox container.
EOF

      # The positional argument is intentionally expanded by the inner shell.
      # shellcheck disable=SC2016
      exec distrobox enter --name "$container_name" -- \
        bash -lc 'cd "$1" && exec ./xsetup' bash "$installer_directory"
    '';
  };

  vitisLauncher = pkgs.writeShellApplication {
    name = "vitis-2023.2";
    runtimeInputs = [ pkgs.distrobox ];
    text = ''
      settings="$HOME/Xilinx/Vitis/2023.2/settings64.sh"
      if [[ ! -f "$settings" ]]; then
        echo "Vitis 2023.2 is not installed; run vitis-2023.2-setup first." >&2
        exit 1
      fi

      # HOME and the arguments are intentionally expanded inside Distrobox.
      # shellcheck disable=SC2016
      exec distrobox enter --name ${lib.escapeShellArg containerName} -- \
        bash -lc 'source "$HOME/Xilinx/Vitis/2023.2/settings64.sh" && exec vitis "$@"' bash "$@"
    '';
  };

  vivadoLauncher = pkgs.writeShellApplication {
    name = "vivado-2023.2";
    runtimeInputs = [ pkgs.distrobox ];
    text = ''
      settings="$HOME/Xilinx/Vivado/2023.2/settings64.sh"
      if [[ ! -f "$settings" ]]; then
        echo "Vivado 2023.2 is not installed; run vitis-2023.2-setup first." >&2
        exit 1
      fi

      # HOME and the arguments are intentionally expanded inside Distrobox.
      # shellcheck disable=SC2016
      exec distrobox enter --name ${lib.escapeShellArg containerName} -- \
        bash -lc 'source "$HOME/Xilinx/Vivado/2023.2/settings64.sh" && exec vivado "$@"' bash "$@"
    '';
  };
in
{
  home.packages = [
    vitisLauncher
    vitisSetup
    vivadoLauncher
  ];
}
