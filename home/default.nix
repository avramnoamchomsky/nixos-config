{ ... }:

{
  imports = [
    ./desktop.nix
    ./dms.nix
    ./input-method.nix
    ./niri.nix
    ./programs.nix
    ./rclone.nix
    ./themes.nix
  ];

  home = {
    username = "chomsky";
    homeDirectory = "/home/chomsky";
    stateVersion = "26.05";

    sessionPath = [ "$HOME/.local/bin" ];
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
