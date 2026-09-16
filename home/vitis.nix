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

      # Container creation normally downloads this helper. Retry explicitly in
      # case a transient network failure interrupted the initial setup.
      distrobox enter --name "$container_name" -- \
        /usr/bin/distrobox-host-exec --yes true >/dev/null 2>&1 || true

      distrobox enter --name "$container_name" -- bash -lc '
        set -euo pipefail
        sudo apt-get update
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
          libasound2 \
          libgtk2.0-0 \
          libgtk-3-0 \
          libnss3 \
          libx11-6 \
          libxext6 \
          libxft2 \
          libxi6 \
          libxinerama1 \
          libxkbcommon-x11-0 \
          libxrandr2 \
          libxrender1 \
          libxtst6 \
          software-properties-common \
          zip
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

  vitisVncServer = pkgs.writeShellApplication {
    name = "vitis-vnc-server";
    runtimeInputs = with pkgs; [
      coreutils
      distrobox
      docker
    ];

    text = ''
      container_name=${lib.escapeShellArg containerName}

      for attempt in {1..60}; do
        if docker info >/dev/null 2>&1; then
          break
        fi

        if [[ "$attempt" -eq 60 ]]; then
          echo "Docker did not become ready within two minutes." >&2
          exit 1
        fi

        sleep 2
      done

      if ! docker container inspect "$container_name" >/dev/null 2>&1; then
        echo "Distrobox $container_name does not exist; run vitis-2023.2-setup first." >&2
        exit 1
      fi

      if [[ ! -s "$HOME/.vnc/passwd" ]]; then
        echo "TigerVNC password is missing; run vncpasswd inside $container_name." >&2
        exit 1
      fi

      distrobox enter --name "$container_name" -- bash -lc '
        vncserver -kill :1 >/dev/null 2>&1 || true
        vncserver -list -cleanstale >/dev/null 2>&1 || true
      '

      # HOME is intentionally expanded by the inner Ubuntu shell.
      # shellcheck disable=SC2016
      exec distrobox enter --name "$container_name" -- bash -lc '
        exec vncserver :1 \
          -fg \
          -localhost yes \
          -geometry 1920x1080 \
          -depth 24 \
          -xstartup "$HOME/.vnc/xstartup"
      '
    '';
  };

  vitisVncStop = pkgs.writeShellApplication {
    name = "vitis-vnc-stop";
    runtimeInputs = [ pkgs.distrobox ];
    text = ''
      distrobox enter --name ${lib.escapeShellArg containerName} -- \
        bash -lc 'vncserver -kill :1 >/dev/null 2>&1 || true'
    '';
  };
in
{
  home.packages = [
    vitisLauncher
    vitisSetup
    vitisVncServer
    vitisVncStop
    vivadoLauncher
  ];

  systemd.user.services.vitis-vnc = {
    Unit = {
      Description = "Vitis Ubuntu Distrobox VNC desktop";
      ConditionPathExists = "%h/.vnc/passwd";
    };

    Service = {
      Type = "simple";
      ExecStart = lib.getExe vitisVncServer;
      ExecStop = lib.getExe vitisVncStop;
      Restart = "always";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
