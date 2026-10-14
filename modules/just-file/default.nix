{ inputs, ... }:
let
  justFileModule = {
    imports = [
      "${inputs.files}/flake-module.nix"
      ../../lib/just-file/options.nix
      ../../lib/just-file/realize.nix
    ];
  };
in
{
  flake.flakeModules.default = justFileModule;
}
