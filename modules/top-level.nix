{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.repo;
  inherit (lib) mapAttrs mkOption nameValuePair types;

  mkNixosConfiguration = hostname: host:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        cfg.cachix
        inputs.stylix.nixosModules.stylix
        cfg.nixosModules.common
        host.module
        inputs.home-manager.nixosModules.home-manager
        {
          nix.settings.substituters = ["https://attic.xuyh0120.win/lantian"];
          nix.settings.trusted-public-keys = ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];

          home-manager = {
            useUserPackages = true;
            backupFileExtension = "backup";
            users.${host.username} = cfg.homeProfiles.${host.homeProfile};
          };
        }
        inputs.determinate.nixosModules.default
      ];
    };

  mkStandaloneHome = name: home:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgsFor home.system;
      modules = [
        inputs.stylix.homeManagerModules.stylix
        cfg.homeProfiles.${home.profile}
      ];
    };

  nixpkgsFor = system: inputs.nixpkgs.legacyPackages.${system};
in {
  options.repo = {
    cachix = mkOption {
      type = types.unspecified;
      default = import ../cachix.nix;
    };

    overlays = mkOption {
      type = types.attrsOf types.unspecified;
      default = {};
    };

    packageBuilders = mkOption {
      type = types.attrsOf types.unspecified;
      default = {};
    };

    nixosModules = mkOption {
      type = types.attrsOf types.deferredModule;
      default = {};
    };

    homeManagerModules = mkOption {
      type = types.attrsOf types.raw;
      default = {};
    };

    homeProfiles = mkOption {
      type = types.attrsOf types.deferredModule;
      default = {};
    };

    hosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          username = mkOption {type = types.str;};
          homeProfile = mkOption {type = types.str;};
          module = mkOption {type = types.deferredModule;};
        };
      });
      default = {};
    };

    standaloneHomes = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          system = mkOption {type = types.str;};
          profile = mkOption {type = types.str;};
        };
      });
      default = {};
    };
  };

  config.flake = {
    nixosModules = cfg.nixosModules;
    homeManagerModules = cfg.homeManagerModules;
    cachix = cfg.cachix;
    nixosConfigurations = mapAttrs mkNixosConfiguration cfg.hosts;
    homeConfigurations = mapAttrs mkStandaloneHome cfg.standaloneHomes;
  };
}
