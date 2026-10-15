{ ... }:
{
  just-file.recipes.deploy = {
    args = [
      { name = "target"; }
      {
        name = "mode";
        default = "'safe mode'";
      }
    ];
    text = "printf '<%s><%s>\\n' '{{target}}' '{{mode}}'";
  };

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-args-order";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.just
      ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        grep -F "deploy target mode='safe mode':" Justfile
        just deploy alpha | grep -F "<alpha><safe mode>"
      '';
    };
  };
}
