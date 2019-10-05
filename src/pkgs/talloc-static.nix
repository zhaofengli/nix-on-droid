# Licensed under GNU Lesser General Public License v3 or later, see COPYING.
# Copyright (c) 2019 Alexander Sosedkin and other contributors, see AUTHORS.

{ pinnedPkgs }:  # just unpinned pkgs. non-cross and non-static. wow.

pinnedPkgs.stdenv.mkDerivation rec {
  name = "talloc-2.1.14";

  src = pinnedPkgs.fetchurl {
    url = "mirror://samba/talloc/${name}.tar.gz";
    sha256 = "1kk76dyav41ip7ddbbf04yfydb4jvywzi2ps0z2vla56aqkn11di";
  };

  depsBuildBuild = [ pinnedPkgs.python2 pinnedPkgs.zlib ];

  buildDeps = [ pinnedPkgs.zlib ];

  configurePhase = ''
    substituteInPlace buildtools/bin/waf \
      --replace "/usr/bin/env python" "${pinnedPkgs.python2}/bin/python"
    ./configure --prefix=$out \
      --disable-rpath \
      --disable-python \
  '';

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/lib
    make install
    gcc-ar q $out/lib/libtalloc.a bin/default/talloc_[0-9]*.o
  '';

  fixupPhase = "";
}
