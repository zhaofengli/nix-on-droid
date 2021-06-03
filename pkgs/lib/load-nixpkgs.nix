# Copyright (c) 2019-2020, see AUTHORS. Licensed under MIT License, see LICENSE.

let
  defaultNixpkgsArgs = {
    config = { };
    overlays = [
      (self: super: {
        gdb = super.gdb.override {
          # actual default value of safePaths, but `lib` does not exist when cross-compiling:
          # [
          #   # $debugdir:$datadir/auto-load are whitelisted by default by GDB
          #   "$debugdir" "$datadir/auto-load"
          #   # targetPackages so we get the right libc when cross-compiling and using buildPackages.gdb
          #   targetPackages.stdenv.cc.cc.lib
          # ]
          safePaths = [ "$debugdir" "$datadir/auto-load" ];
        };
      })
    ];
  };

  # head of nixos-21.05 as of 2021-06-03
  # note: when updating nixpkgs, update store paths of proot-termux in modules/environment/login/default.nix
  pinnedPkgsSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/eaba7870ffc3400eca4407baa24184b7fe337ec1.tar.gz";
    sha256 = "115disiz4b08iw46cidc7lm0advrxn5g2ldmlrxd53zf03skyb2w";
  };
in

args: import pinnedPkgsSrc (args // defaultNixpkgsArgs)
