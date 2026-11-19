{ pkgs, ... }:

let
  username = "chomsky";
in
{
  imports = [ (import ../webdav.nix { inherit username; }) ];

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "wheel"
      "networkmanager"
      "plugdev"
      "dialout"
      "wireshark"
      "docker"
      "libvirtd"
    ];
    shell = pkgs.fish;
  };

  services.openssh.settings.AllowUsers = [ username ];

  home-manager.users.${username} = {
    imports = [
      ../../../home/115-life.nix
      ../../../home/baidunetdisk.nix
      ../../../home/desktop.nix
      ./dms.nix
      ../../../home/ghost-downloader.nix
      ../../../home/input-method.nix
      ../../../home/niri.nix
      ../../../home/programs.nix
      ../../../home/themes.nix
      ./vitis.nix
      ../../../home/yazi.nix
    ];

    home = {
      stateVersion = "26.05";

      sessionPath = [ "$HOME/.local/bin" ];
    };

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
    programs.home-manager.enable = true;

    home.file."all_files/projects/esp32/.envrc".text = ''
      use flake ~/all_files/projects/dev-envs/esp32
    '';

    programs.git.settings.user = {
      name = username;
      email = "315812871+avramnoamchomsky@users.noreply.github.com";
    };

    programs.fish = {
      shellAliases = {
        "7sec" = "7z a -t7z -m0=lzma2 -mx=9 -mmt=(nproc) -pcoffee -mhe=on";
        "7zip" = "7z a -t7z -m0=lzma2 -mx=9 -mmt=(nproc)";
        "7secv" = "7z a -t7z -v107374182400b -m0=lzma2 -mx=9 -mmt=(nproc) -pcoffee -mhe=on";
        "7zipv" = "7z a -t7z -v107374182400b -m0=lzma2 -mx=9 -mmt=(nproc)";
      };

      functions.esp32-shell = ''
        nix develop ~/all_files/projects/dev-envs/esp32 -c fish
      '';

      # Only the primary local console launches the desktop. Replacing the
      # shell returns to the login prompt when Niri exits or fails.
      loginShellInit = ''
        if status is-interactive; and test "$(${pkgs.coreutils}/bin/tty)" = /dev/tty1
          and test -z "$SSH_CONNECTION"; and test -z "$WAYLAND_DISPLAY"; and test -z "$DISPLAY"
          exec ${pkgs.niri}/bin/niri-session
        end
      '';
    };

    # MControlCenter's window geometry is deliberately omitted; only hardware
    # behaviour belongs in Git.
    xdg.configFile."MControlCenter.conf" = {
      force = true;
      text = ''
        [Settings]
        UserMode=balanced_mode
        fan1SpeedSettings=30|30|30|30|30|30|30
        fan1TempSettings=50|55|60|65|70|75
        fan2SpeedSettings=30|30|30|30|30|30|30
        fan2TempSettings=55|60|65|70|75|80
        fanModeAdvanced=true
      '';
    };
  };
}
