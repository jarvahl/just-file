{ ... }:
{
  just-file.recipes.deploy = {
    description = "Deploy configuration";
    args = [ { name = "target"; } ];
    attributes = {
      confirm = true;
      group = "deployment";
    };
    text = "deploy {{target}}";
  };

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-attributes";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.just
      ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        grep -F "[group('deployment')]" Justfile
        grep -F "[confirm]" Justfile
        just --dump >/dev/null
      '';
    };
  };
}
