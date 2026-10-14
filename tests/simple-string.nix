{ ... }:
{
  just.recipes.check = "nix flake check";

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-simple-string";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.just
      ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        test -f Justfile
        grep -F "check:" Justfile
        grep -F "    nix flake check" Justfile
        just --dump >/dev/null
      '';
    };
  };
}
