{ ... }:
{
  justFile.recipes.build = {
    description = "Build configuration";
    args = [
      {
        name = "host";
        default = "`hostname`";
      }
    ];
    text = ''
      echo first {{host}}
      echo second
    '';
  };

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-structured";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.just
      ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        grep -F "# Build configuration" Justfile
        grep -F "build host=\`hostname\`:" Justfile
        grep -F "    echo first {{host}}" Justfile
        grep -F "    echo second" Justfile
        just --dump >/dev/null
      '';
    };
  };
}
