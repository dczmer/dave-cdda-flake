{ pkgs, cdda-src }:
pkgs.stdenv.mkDerivation {
  pname = "cataclysm-dda";
  version = "git";
  src = cdda-src;
  # this is required for configuration to pick up shared libs properly
  nativeBuildInputs = with pkgs; [
    pkg-config
  ];
  # this is needed for localization script
  postPatch = ''
    patchShebangs lang/compile_mo.sh
  '';
  makeFlags = [
    "PREFIX=$(out)"
    "USE_XDG_DIR=1"
    "TILES=1"
    "SOUND=1"
    # don't bother localizing
    "LOCALIZE=0"
    #"LANGUAGES=en_US"
  ];
  buildInputs = with pkgs; [
    SDL
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    freetype
  ];
}
