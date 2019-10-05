# Licensed under GNU Lesser General Public License v3 or later, see COPYING.
# Copyright (c) 2019 Alexander Sosedkin and other contributors, see AUTHORS.

# NOTE: This could be so-o simple, really.
#       Pass pkgs.pkgsStatic and build it. Easy-peasy.
#       The problem is, you use pkgsStatic, you hit a cache miss on Hydra.
#       Which means that you end up recompiling the toolchain on your device.
#       And it's not something that I can cache in Cachix once and forget,
#       this is using unpinned nixpkgs and would retrigger all. the. time.
#
#       Thus, here I statically link proot with a regular toolchain. And musl.
#       The wrong way.

{ pinnedPkgs, tallocStatic }:  # non-cross, native (on-device) pkgs.

pinnedPkgs.stdenv.mkDerivation rec {
  pname = "proot-termux";
  version = "unstable-2019-09-05";

  src = pinnedPkgs.fetchFromGitHub {
    repo = "proot";
    owner = "termux";
    rev = "3ea655b1ae40bfa2ee612d45bf1e7ad97c4559f8";
    sha256 = "05y30ifbp4sn1pzy8wlifc5d9n2lrgspqzdjix1kxjj9j9947qgd";
  };

  #pname = "proot-upstream";
  #version = "unstable-2019-10-06";
  #src = pinnedPkgs.fetchFromGitHub {
  #  repo = "proot";
  #  owner = "proot-me";
  #  rev = "037e77ef796cf4f10e170007a9929bdc400ca3de";
  #  sha256 = "0x81b3018g6bszmjsxbx8qffph4chfj6p5zkfvblsv7aiq8hqx4s";
  #};

  buildInputs = [ tallocStatic pinnedPkgs.llvm pinnedPkgs.glibc.static ];

  CC = "llvm";
  CFLAGS = "-D__ANDROID__";
  LDFLAGS = "-static";
  makeFlags = [ "-Csrc CFLAGS=-D__ANDROID__" ];

  installPhase = ''
    install -D -m 0755 src/proot $out/bin/proot-static
  '';
  fixupPhase = "";
}
