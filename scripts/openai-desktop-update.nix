let
  repo = builtins.getFlake (builtins.getEnv "OPENAI_UPDATE_REPO");
  pkgs = repo.nixosConfigurations.Pisces.pkgs;
  adapter = builtins.getFlake ("path:" + builtins.getEnv "OPENAI_UPDATE_ADAPTER");
  desktop = adapter.packages.x86_64-linux.codex-desktop;
in
{
  cli = pkgs.callPackage ../home/packages/codex.nix {
    releaseVersion = builtins.getEnv "OPENAI_UPDATE_CLI_VERSION";
    releaseHash = builtins.getEnv "OPENAI_UPDATE_CLI_HASH";
  };

  desktop = pkgs.symlinkJoin {
    inherit (desktop) name;
    paths = [ desktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm "$out/bin/codex-desktop"
      makeWrapper ${desktop}/bin/codex-desktop "$out/bin/codex-desktop" \
        --run 'if [[ -z ''${CODEX_CLI_PATH:-} && -x $HOME/.local/bin/codex ]]; then export CODEX_CLI_PATH="$HOME/.local/bin/codex"; fi'
      entry="$out/share/applications/codex-desktop.desktop"
      rm "$entry"
      substitute ${desktop}/share/applications/codex-desktop.desktop "$entry" \
        --replace-fail "${desktop}/bin/codex-desktop" "$out/bin/codex-desktop"
    '';
  };
}
