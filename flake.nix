#
# Simple Catclysm-DDA experimental build as a flake.
#
# The source and mod revs are frozen at latest version when you install.
# Run `nix flake update` to update everything to latest rev at once.
# Restore flake.lock to roll-back.
#
#
# I found an existing nixpkg:
#
#   https://ryantm.github.io/nixpkgs/builders/packages/cataclysm-dda/#cataclysm-dark-days-ahead
#
# It allows you to install the development branch and has builders to easily
# package and install mods.
#
# However, it's frozen at a rev from 08/2022 :(
# But, it allows you to override the revision and hash so that you can use the
# latest development rev!
#
# But it has a bit that unconditionally applies a localization patch that
# doesn't apply cleanly on master :(
#
#   https://github.com/NixOS/nixpkgs/blob/master/pkgs/games/cataclysm-dda/git.nix#L26
#
# I also wanted it to be a flake, and have the versions of the source and any
# out-of-repo mods in the flake.lock file.
# Then I can update everything at once with `git flake update` and I can
# roll-back by restoring the lockfile from git history.
#
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
  outputs = inputs @ {
    self,
    nixpkgs,
    cdda-src,
    UnDeadPeople-src,
    CDDA-Soundpacks-src
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
      cdda-mods.UnDeadPeopleTileSet = UnDeadPeopleTileSet;
    };
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = [ flakeOverlay ];
    };
  in {
    packages.x86_64-linux.default = pkgs.cataclysm-dda-git;
    apps.x86_64-linux.default = {
      type = "app";
      program = "${pkgs.cataclysm-dda-git}/bin/cataclysm-tiles";
    };
  };
}
