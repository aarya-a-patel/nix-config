{...}: {
  config = {
    perSystem = {pkgs, ...}: {
      formatter = pkgs.alejandra;
    };
  };
}
