{ lib, config, ... }:
let
  cfg = config.just;
  render = import ../render.nix { inherit lib; };
  runtimeRecipes = lib.filterAttrs (_: recipe: recipe.runtimeInputs != null) cfg.recipes;
  justfileText = render.renderJustfile cfg.recipes;
in
{
  perSystem =
    { pkgs, ... }:
    {
      apps = lib.mapAttrs' (
        name: recipe:
        let
          app = pkgs.writeShellApplication {
            name = "just-${name}";
            runtimeInputs = [ pkgs.just ] ++ recipe.runtimeInputs { inherit pkgs; };
            text = ''
              justfile=$(mktemp)
              trap 'rm -f "$justfile"' EXIT
              printf '%s' ${
                lib.escapeShellArg (render.renderRecipe "__just_file_recipe" (recipe // { attributes = { }; }))
              } > "$justfile"
              exec just --justfile "$justfile" --working-directory "$PWD" __just_file_recipe "$@"
            '';
          };
        in
        lib.nameValuePair "just-${name}" {
          type = "app";
          program = lib.getExe app;
        }
      ) runtimeRecipes;

      files = {
        file."Justfile".text = justfileText;
        writer.app = true;
      };
    };
}
