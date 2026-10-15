{ ... }:
{
  just-file.recipes.capture = {
    description = "Capture one argument";
    args = [ { name = "value"; } ];
    runtimeInputs = { pkgs }: [ pkgs.coreutils ];
    text = ''
      printf '%s\n' '{{value}}' > captured.txt
    '';
  };

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-runtime-app";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.just
        pkgs.nix
      ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        grep -F "# Capture one argument" Justfile
        grep -F "capture value:" Justfile
        grep -F '    nix run .#just-capture -- {{quote(value)}}' Justfile
        nix eval --raw .#apps.${pkgs.system}.just-capture.type | grep -F app
        just capture 'hello world'
        grep -Fx 'hello world' captured.txt
      '';
    };
  };
}
