# Description

Simple Catclysm-DDA experimental build as a flake.

The source and mod revs are frozen at latest version when you install.
Run `nix flake update` to update everything to latest rev at once.
Restore flake.lock to roll-back.


# Notes

I found an existing nixpkg [HERE](https://ryantm.github.io/nixpkgs/builders/packages/cataclysm-dda/#cataclysm-dark-days-ahead).

It allows you to install the development branch and has builders to easily
package and install mods.

However, it's frozen at a rev from 08/2022 :(
But, it allows you to override the revision and hash so that you can use the
latest development rev!

But it has a bit that unconditionally applies a localization patch that
doesn't apply cleanly on master :(

  [ISSUE](https://github.com/NixOS/nixpkgs/blob/master/pkgs/games/cataclysm-dda/git.nix#L26)

I also wanted it to be a flake, and have the versions of the source and any
out-of-repo mods in the flake.lock file.
Then I can update everything at once with `git flake update` and I can
roll-back by restoring the lockfile from git history.


# TODO

- [ ] possible to link/merge some default config settings?
