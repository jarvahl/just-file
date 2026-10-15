{ ... }:
{
  just-file.recipes.check = "nix flake check";

  perSystem = { config, pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-simple-string";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.just
        pkgs.nix
      ];
      text = ''
        ${config.files.writer.drv}/bin/write-files
        test -f Justfile
        grep -F "DO-NOT-EDIT. This file was auto-generated using github:jarvahl/just-file." Justfile
        grep -F "Use \`nix run .#write-files\` to regenerate it." Justfile
        grep -F "check:" Justfile
        grep -F "    nix flake check" Justfile
        just --dump >/dev/null
        ${config.files.writer.drv}/bin/write-files
      '';
    };
  };
}
