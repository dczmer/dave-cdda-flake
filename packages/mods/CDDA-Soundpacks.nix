{ pkgs, CDDA-Soundpacks-src }:
pkgs.stdenv.mkDerivation {
  name = "CDDA-Soundpacks";
  version = "git";
  src = CDDA-Soundpacks-src;
  installPhase = ''
    mkdir -p $out/share/cataclysm-dda/sound
    cp -r ./sound/CC-Sounds $out/share/cataclysm-dda/sound/CC-Sounds
  '';
}
