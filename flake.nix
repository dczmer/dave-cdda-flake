{
  description = "CDDA Experimental flake";
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
    };
    cdda-src = {
      url = "github:CleverRaven/Cataclysm-DDA";
      flake = false;
    };
    UnDeadPeople-src = {
      url = "github:Theawesomeboophis/UnDeadPeopleTileSet";
      flake = false;
    };
    CDDA-Soundpacks-src = {
      url = "github:Fris0uman/CDDA-Soundpacks";
      flake = false;
    };
  };
  outputs =
    {
      nixpkgs,
      cdda-src,
      UnDeadPeople-src,
      CDDA-Soundpacks-src,
      ...
    }:
    let
      cataclysm-unwrapped = import ./packages/cataclysm-dda-git.nix {
        inherit pkgs cdda-src;
      };
      UnDeadPeopleTileSet = import ./packages/mods/UnDeadPeopleTileSet.nix {
        inherit pkgs UnDeadPeople-src;
      };
      CDDA-Soundpacks = import ./packages/mods/CDDA-Soundpacks.nix {
        inherit pkgs CDDA-Soundpacks-src;
      };
      # symlinkJoin the paths for the mods with the cdda install path.
      # this lets them all be cached individually and overlay at run-time.
      # TODO: extract this symlinkJoin bit to another package (cdda-wrapped).
      cataclysm-dda-git = pkgs.symlinkJoin {
        name = "cataclysm-dda-git-with-mods";
        paths = [
          cataclysm-unwrapped
          UnDeadPeopleTileSet
          CDDA-Soundpacks
        ];
        # makeWrapper provides `wrapProgram`
        nativeBuildInputs = with pkgs; [
          makeWrapper
        ];
        # wrap the program and add `--datadir` to pickup our joined mods path
        postBuild = ''
          wrapProgram $out/bin/cataclysm-tiles \
              --add-flags "--datadir $out/share/cataclysm-dda/"
        '';
      };
      flakeOverlay = prev: final: {
        cataclysm-dda-git = cataclysm-dda-git;
      };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ flakeOverlay ];
      };
    in
    {
      packages.x86_64-linux.default = pkgs.cataclysm-dda-git;
      apps.x86_64-linux.default = {
        type = "app";
        program = "${pkgs.cataclysm-dda-git}/bin/cataclysm-tiles";
      };
    };
}
