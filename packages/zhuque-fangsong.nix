{ lib, stdenvNoCC, fetchurl, unzip }:

stdenvNoCC.mkDerivation {
  pname = "zhuque-fangsong";
  version = "0.212";

  # Upstream publishes this version as a technical preview. Pin the official
  # release archive without changing its font names or the desktop defaults.
  src = fetchurl {
    url = "https://github.com/TrionesType/zhuque/releases/download/v0.212/ZhuqueFangsong-v0.212.zip";
    hash = "sha256-u4tmGnZD0ilqctnRBTCgCUlBnE5Sf7YXg/c8K6GowGI=";
  };

  nativeBuildInputs = [ unzip ];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -d "$out/share/fonts/truetype"
    unzip -p "$src" ZhuqueFangsong-Regular.ttf \
      > "$out/share/fonts/truetype/ZhuqueFangsong-Regular.ttf"
    runHook postInstall
  '';

  meta = {
    description = "Zhuque Fangsong Chinese font (technical preview)";
    homepage = "https://github.com/TrionesType/zhuque";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
