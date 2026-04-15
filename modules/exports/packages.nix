{
  config,
  lib,
  ...
}: {
  config = {
    perSystem = {pkgs, ...}: {
      packages =
        lib.filterAttrs (_: lib.isDerivation)
        (builtins.mapAttrs (_: builder: builder pkgs) config.repo.packageBuilders);
      formatter = pkgs.alejandra;
    };
  };
}
