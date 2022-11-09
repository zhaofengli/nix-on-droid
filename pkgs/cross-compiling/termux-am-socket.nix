# Copyright (c) 2019-2022, see AUTHORS. Licensed under MIT License, see LICENSE.

{ callPackage }:

let
  pkgsCross = callPackage ./cross-pkgs.nix { };
  stdenv = pkgsCross.stdenvAdapters.makeStaticBinaries pkgsCross.stdenv;

in
  pkgsCross.callPackage ../termux-am-socket {
    inherit stdenv;
  }
