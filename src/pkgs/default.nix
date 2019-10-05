# Licensed under GNU Lesser General Public License v3 or later, see COPYING.
# Copyright (c) 2019 Alexander Sosedkin and other contributors, see AUTHORS.

{ arch, buildPkgs, crossPinnedPkgs, crossStaticPinnedPkgs, pinnedPkgs, initialBuild
, nixOnDroidChannelURL, nixpkgsChannelURL
} @ args:

let
  callPackage = buildPkgs.lib.callPackageWith (args // pkgs);

  pkgs = rec {
    bootstrap = callPackage ./bootstrap.nix { };

    bootstrapZip = callPackage ./bootstrap-zip.nix { };

    files = callPackage ./files { } // { recurseForDerivations = true; };

    ids = callPackage ./ids.nix { };

    nixDirectory = callPackage ./nix-directory.nix { };

    proot-static = if initialBuild then
      callPackage ./proot-static-cross.nix {
        inherit crossStaticPinnedPkgs;
        tallocStatic = callPackage ./talloc-static-cross.nix { };
      }
    else
      callPackage ./proot-static.nix {
        pkgs = buildPkgs;
        tallocStatic = callPackage ./talloc-static.nix { pkgs = buildPkgs; };
      };

    qemuAarch64Static = callPackage ./qemu-aarch64-static.nix { };
  };
in

pkgs
