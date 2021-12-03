# Copyright (c) 2019-2021, see AUTHORS. Licensed under MIT License, see LICENSE.

{ config, lib, pkgs, home-manager, ... }:

with lib;

let
  cfg = config.home-manager;

  extendedLib = import (home-manager + "/modules/lib/stdlib-extended.nix") pkgs.lib;

  hmModule = types.submoduleWith {
    specialArgs = { lib = extendedLib; };
    modules = [
      ({ name, ... }: {
        imports = import (home-manager + "/modules/modules.nix") {
          inherit pkgs;
          lib = extendedLib;
          useNixpkgsModule = !cfg.useGlobalPkgs;
        };

        config = {
          submoduleSupport.enable = true;
          submoduleSupport.externalPackageInstall = cfg.useUserPackages;

          home.username = config.user.userName;
          home.homeDirectory = config.user.home;
        };
      })
    ];
  };
in

{

  ###### interface

  options = {

    home-manager = {
      backupFileExtension = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "backup";
        description = ''
          On activation move existing files by appending the given
          file extension rather than exiting with an error.
        '';
      };

      config = mkOption {
        type = types.nullOr hmModule;
        default = null;
        description = "Home Manager configuration.";
      };

      useGlobalPkgs = mkEnableOption ''
        using the system configuration's <literal>pkgs</literal>
        argument in Home Manager. This disables the Home Manager
        options <option>nixpkgs.*</option>
      '';

      useUserPackages = mkEnableOption ''
        installation of user packages through the
        <option>environment.packages</option> option.
      '' // {
        default = versionAtLeast config.system.stateVersion "20.09";
      };
    };

  };


  ###### implementation

  config = mkIf (cfg.config != null) {

    inherit (cfg.config) assertions warnings;

    build = {
      activationBefore = mkIf cfg.useUserPackages {
        setPriorityHomeManagerPath = ''
          if nix-env -q | grep '^home-manager-path$'; then
            $DRY_RUN_CMD nix-env $VERBOSE_ARG --set-flag priority 120 home-manager-path
          fi
        '';
      };

      activationAfter.homeManager = concatStringsSep " " (
        optional
          (cfg.backupFileExtension != null)
          "HOME_MANAGER_BACKUP_EXT='${cfg.backupFileExtension}'"
        ++ [ "${cfg.config.home.activationPackage}/activate" ]
      );
    };

    environment.packages = mkIf cfg.useUserPackages cfg.config.home.packages;

    # home-manager has a quirk redefining the profile location
    # to "/etc/profiles/per-user/${cfg.username}" if useUserPackages is on.
    # https://github.com/nix-community/home-manager/blob/0006da1381b87844c944fe8b925ec864ccf19348/modules/home-environment.nix#L414
    # Fortunately, it's not that hard to us to workaround with just a symlink.
    environment.etc = mkIf cfg.useUserPackages {
      "profiles/per-user/${config.user.userName}".source =
        builtins.toPath "${config.user.home}/.nix-profile";
    };

  };
}
