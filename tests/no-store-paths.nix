{ ... }:
{
  just-file.recipes.format = {
    runtimeInputs = { pkgs }: [ pkgs.coreutils ];
    text = "true";
  };

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-no-store-paths";
      runtimeInputs = [ pkgs.gnugrep ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        test -f Justfile
        test ! -L Justfile
        if grep -F /nix/store Justfile; then
          exit 1
        fi
      '';
    };
  };
}
