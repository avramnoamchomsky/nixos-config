{ pkgs, unstablePkgs, ... }:

let
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
    google-chrome
    mpv
    vscode
    gh
    unstablePkgs.qq
    wechat-fcitx

    # Development tools
    unstablePkgs.codex
    nodejs
    python3
    unstablePkgs.uv
    stm32cubemx

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
