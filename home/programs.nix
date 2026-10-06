{ pkgs, unstablePkgs, ... }:

let
  browser115 = import ./packages/115-browser.nix { inherit pkgs; };
  sylvakru = import ./packages/sylvakru.nix { inherit pkgs; };
  readest = unstablePkgs.callPackage ./packages/readest.nix { };

  # ROCm SMI otherwise searches /usr/share for pci.ids and names the iGPU
  # "0x1002" on NixOS. Point this monitoring dependency at the packaged data.
  rocmSmi = pkgs.rocmPackages.rocm-smi.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/rocm_smi.cc \
        --replace-fail '"/usr/share/hwdata/pci.ids"' '"${pkgs.hwdata}/share/hwdata/pci.ids"'
    '';
  });

  sevenZip = pkgs.symlinkJoin {
    name = "7zip-with-7z-alias";
    paths = [ pkgs._7zz ];
    postBuild = ''
      ln -s "$out/bin/7zz" "$out/bin/7z"
    '';
  };

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

  wpsOffice = pkgs.symlinkJoin {
    name = "wpsoffice-cn-fcitx-${pkgs.wpsoffice-cn.version}";
    paths = [ pkgs.wpsoffice-cn ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      # WPS uses bundled Qt under XWayland, so select Fcitx explicitly.
      for program in wps et wpp wpspdf; do
        wrapProgram "$out/bin/$program" \
          --set XMODIFIERS "@im=fcitx" \
          --set QT_IM_MODULE "fcitx" \
          --set GTK_IM_MODULE "fcitx" \
          --set QT_QPA_PLATFORM "xcb"
      done

      # Desktop entries otherwise bypass these wrappers via the base package.
      for desktop in "$out"/share/applications/*.desktop; do
        cp "$desktop" "$desktop.tmp"
        mv "$desktop.tmp" "$desktop"
        substituteInPlace "$desktop" \
          --replace-fail "${pkgs.wpsoffice-cn}/bin/" "$out/bin/"
      done
    '';

    meta = pkgs.wpsoffice-cn.meta;
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

  programs.fish = {
    enable = true;

    shellAliases = {
      "7sec" = "7z a -t7z -m0=lzma2 -mx=9 -mmt=(nproc) -pcoffee -mhe=on";
      "7zip" = "7z a -t7z -m0=lzma2 -mx=9 -mmt=(nproc)";
      "7secv" = "7z a -t7z -v107374182400b -m0=lzma2 -mx=9 -mmt=(nproc) -pcoffee -mhe=on";
      "7zipv" = "7z a -t7z -v107374182400b -m0=lzma2 -mx=9 -mmt=(nproc)";
    };

    functions.esp32-shell = ''
      nix develop ~/all_files/projects/dev-envs/esp32 -c fish
    '';
  };

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

  programs.btop = {
    enable = true;
    # Enable discovery of NVML and ROCm SMI on this hybrid NVIDIA/AMD laptop.
    package = pkgs.btop.override {
      cudaSupport = true;
      rocmSupport = true;
      rocmPackages = pkgs.rocmPackages // { rocm-smi = rocmSmi; };
    };
  };

  programs.obs-studio.enable = true;

  home.packages = with pkgs; [
    # Graphical applications
    browser115
    google-chrome
    readest
    sylvakru
    mpv
    remmina
    kdiskmark
    vscode
    gh
    unstablePkgs.qq
    wechat-fcitx
    wpsOffice
    gimp
    blender
    audacity
    kdePackages.kdenlive
    drawio
    freeplane
    zotero
    qalculate-gtk
    swayimg
    satty
    qpwgraph
    seahorse
    moonlight-qt

    # Development tools
    unstablePkgs.codex
    nodejs
    conan
    pnpm
    # Keep GCC's cc/c++/cpp aliases as defaults when both toolchains exist.
    (pkgs.lib.setPrio 15 llvmPackages.clang)
    clang-tools
    # The ARM toolchain also exports include/gdb/jit-reader.h. Keep its
    # existing shared header while adding the unprefixed host debugger.
    (pkgs.lib.lowPrio gdb)
    shellcheck
    shfmt
    dtc

    (python3.withPackages (ps: with ps; [
      pip
      virtualenv
    ]))

    unstablePkgs.uv

    # HDL development
    iverilog
    verilator
    verible
    surfer
    # Keep Yosys and SymbiYosys together: stable Yosys passes obsolete CLI
    # flags to modern Bitwuzla, while this pinned unstable pair has the fix.
    unstablePkgs.yosys
    unstablePkgs.sby
    nextpnr
    bitwuzla
    yices # Default solver for SymbiYosys's smtbmc engine
    gcc
    gnumake # Build Verilator's generated C++ simulations

    # Android device maintenance and firmware images
    android-tools
    payload-dumper-go

    # STM32 development
    stm32cubemx
    gcc-arm-embedded
    cmake
    ninja
    openocd
    stlink
    tio

    # Electronics, CAD, and serial-data visualization
    kicad
    freecad
    serial-studio
    ngspice

    # Media commands exposed to the shell, including GStreamer's plugin search
    # through the Nix profiles rather than a manually maintained environment.
    ffmpeg-headless
    imagemagick
    gst_all_1.gstreamer
    # The default bin output omits core elements such as typefind/fakesink.
    gst_all_1.gstreamer.out
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav

    (texlive.combine {
      inherit (texlive)
        scheme-medium
        collection-luatex
        collection-xetex
        collection-bibtexextra
        collection-langchinese
        ;
    })

    # Wayland utilities
    wl-clipboard
    wlr-randr

    # General CLI tools
    curl
    wget
    rsync
    openssh
    ripgrep
    fd
    jq
    sevenZip
    tealdeer
    fastfetch
    duf
    lazygit
    gdu
    zellij
    lazyjournal
    systemctl-tui
    wiremix
    # NVTOP only needs NVML headers for NVIDIA monitoring. Supplying the
    # focused development package avoids downloading the whole CUDA toolkit.
    (nvtopPackages.full.override {
      cudatoolkit = cudaPackages.cuda_nvml_dev;
    })
    amdgpu_top
    hardinfo2
    exfatprogs
    clinfo
    dmidecode
    psmisc
    file
    zip
    unzip

    # Network diagnostics and command-line remote access. These packages do
    # not start servers; capture capabilities are configured by NixOS.
    nmap
    zenmap
    iperf3
    lsof
    sshfs
    traceroute
    whois
    freerdp
    atftp
  ];
}
