# Copyright (c) 2019-2020, see AUTHORS. Licensed under MIT License, see LICENSE.

{ super }:

let
  # head of nixos-21.05 as of 2021-06-03
  pinnedPkgsSrc = super.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "eaba7870ffc3400eca4407baa24184b7fe337ec1";
    sha256 = "115disiz4b08iw46cidc7lm0advrxn5g2ldmlrxd53zf03skyb2w";
  };

in

import pinnedPkgsSrc {
  inherit (super) config;
  overlays = [ ];
}
