{ lib, ... }:
let
  argType = lib.types.submodule {
    options = {
      default = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
      };

      name = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  recipeType = lib.types.submodule {
    options = {
      args = lib.mkOption {
        default = [ ];
        type = lib.types.listOf argType;
      };

      attributes = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (
          lib.types.oneOf [
            lib.types.bool
            lib.types.str
          ]
        );
      };

      description = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
      };

      runtimeInputs = lib.mkOption {
        default = null;
        type = lib.types.nullOr (lib.types.functionTo (lib.types.listOf lib.types.package));
      };

      text = lib.mkOption {
        type = lib.types.lines;
      };
    };
  };
in
{
  options.justFile.recipes = lib.mkOption {
    default = { };
    type = lib.types.attrsOf (lib.types.coercedTo lib.types.str (text: { inherit text; }) recipeType);
  };
}
