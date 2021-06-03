# Copyright (c) 2019-2020, see AUTHORS. Licensed under MIT License, see LICENSE.

{ callPackage, fetchFromGitHub, tallocStatic }:

let
  pkgs = callPackage ./pkgs.nix { };
in

pkgs.crossStatic.stdenv.mkDerivation {
  pname = "proot-termux";
  version = "unstable-2021-05-03";

  src = fetchFromGitHub {
    repo = "proot";
    owner = "termux";
    rev = "8f67d6c7fadb445b7a528020d05e72dba717c5b9";
    sha256 = "0xlfaph2nx3y8jk3jyjb00n44sbzhj89liv7ndf9ss39mzichh1n";
  };

  buildInputs = [ tallocStatic ];

  patches = [ ./proot-detranslate-empty.patch ];

  makeFlags = [ "-Csrc CFLAGS=-D__ANDROID__" ];

  installPhase = ''
    install -D -m 0755 src/proot $out/bin/proot-static
  '';
}
