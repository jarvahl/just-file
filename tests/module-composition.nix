{ lib, ... }:
{
  justFile.recipes = lib.mkMerge [
    {
      check = lib.mkDefault "echo default";
      format = "echo format";
    }
    {
      check = lib.mkForce "echo forced";
    }
  ];

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-module-composition";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.just
      ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        grep -F "    echo forced" Justfile
        grep -F "format:" Justfile
        if grep -F "echo default" Justfile; then
          exit 1
        fi
        just --dump >/dev/null
      '';
    };
  };
}
