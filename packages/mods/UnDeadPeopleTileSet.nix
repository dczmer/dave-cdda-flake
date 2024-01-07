{ pkgs, UnDeadPeople-src }:
pkgs.stdenv.mkDerivation {
  name = "UnDeadPeopleTileSet";
  version = "git";
  src = UnDeadPeople-src;
  installPhase = ''
    mkdir -p $out/share/cataclysm-dda/gfx
    cp -r ./TILESETS/gfx/MSX++UnDeadPeopleEdition $out/share/cataclysm-dda/gfx/UnDeadPeople
  '';
}
