{ pkgs, unstablePkgs, ... }:

let
  browser115 = import ./packages/115-browser.nix { inherit pkgs; };
  sylvakru = import ./packages/sylvakru.nix { inherit pkgs; };

  wechat-fcitx = pkgs.symlinkJoin {
    name = "wechat-fcitx";
    paths = [ pkgs.wechat ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/wechat \
        --set XMODIFIERS "@im=fcitx" \
        --set QT_IM_MODULE "fcitx" \
        --set GTK_IM_MODULE "fcitx" \
        --set QT_QPA_PLATFORM "xcb"
    '';
  };
in
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "chomsky";
        email = "315812871+avramnoamchomsky@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.fish.enable = true;
  programs.fish.functions.esp32-shell = ''
    nix develop ~/all_files/projects/dev-envs/esp32 -c fish
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.file."all_files/projects/esp32/.envrc".text = ''
    use flake ~/all_files/projects/dev-envs/esp32
  '';

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat.enable = true;

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.btop.enable = true;

  programs.obs-studio.enable = true;

  home.packages = with pkgs; [
    # Graphical applications
    browser115
    google-chrome
    unstablePkgs.readest
    sylvakru
    mpv
    vscode
    gh
    unstablePkgs.qq
    wechat-fcitx

    # Development tools
    unstablePkgs.codex
    nodejs

    (python3.withPackages (ps: with ps; [
      pip
      virtualenv
    ]))

    unstablePkgs.uv

    # STM32 development
    stm32cubemx
    gcc-arm-embedded
    cmake
    ninja
    openocd
    stlink

    # Wayland utilities
    wl-clipboard

    # General CLI tools
    curl
    wget
    rsync
    openssh
    ripgrep
    fd
    jq
    tealdeer
    fastfetch
    lazygit
  ];
}
