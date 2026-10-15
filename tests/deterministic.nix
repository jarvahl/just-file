{ ... }:
{
  justFile.recipes = {
    zebra = "echo z";
    alpha = "echo a";
    middle = "echo m";
  };

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-deterministic";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        first=$(sha256sum Justfile)
        ${config.files.writer.drv}/bin/write-files
        second=$(sha256sum Justfile)
        test "$first" = "$second"
        test "$(grep -n '^alpha:\|^middle:\|^zebra:' Justfile | cut -d: -f2 | paste -sd ' ' -)" = "alpha middle zebra"
      '';
    };
  };
}
