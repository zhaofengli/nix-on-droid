# Copyright (c) 2019-2022, see AUTHORS. Licensed under MIT License, see LICENSE.

{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "termux-am-socket";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "termux";
    repo = "termux-am-socket";
    rev = version;
    hash = "sha256-6pCv2HMBRp8Hi56b43mQqnaFaI7y5DfhS9gScANwg2I=";
  };

  nativeBuildInputs = [ cmake ];
}
