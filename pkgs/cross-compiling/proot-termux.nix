# Copyright (c) 2019-2020, see AUTHORS. Licensed under MIT License, see LICENSE.

{ callPackage, fetchFromGitHub, tallocStatic }:

let
  pkgs = callPackage ./pkgs.nix { };
in

pkgs.cross.stdenv.mkDerivation {
  pname = "proot-termux";
  version = "unstable-2021-05-03";

  src = fetchFromGitHub {
    repo = "proot";
    owner = "termux";
    rev = "8f67d6c7fadb445b7a528020d05e72dba717c5b9";
    sha256 = "0xlfaph2nx3y8jk3jyjb00n44sbzhj89liv7ndf9ss39mzichh1n";

    # 1 step behind 6f12fbee "Implement shmat", use if ashmem.h is missing
    #rev = "ffd811ee726c62094477ed335de89fc107cadf17";
    #sha256 = "1zjblclsybvsrjmq2i0z6prhka268f0609w08dh9vdrbrng117f8";

  };

  #LDFLAGS = [ "-static" "-ltalloc" "-shared" ];
  #buildInputs = [ tallocStatic ];
  CFLAGS = [ "-I${tallocStatic}/include" ];
  LDFLAGS = [ "${tallocStatic}/lib/libtalloc.a" ];

  patches = [ ./proot-detranslate-empty.patch ];

  makeFlags = [ "-Csrc" "V=1" ];

  postPatch = ''
    substituteInPlace src/GNUmakefile --replace '-ltalloc' ""
  '';

  installPhase = ''
    install -D -m 0755 src/proot $out/bin/proot-static
  '';
}
