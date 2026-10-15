{ lib }:
let
  concatLines = lib.concatStringsSep "\n";

  indentBody =
    text:
    text
    |> lib.splitString "\n"
    |> map (line: if line == "" then "" else "    ${line}")
    |> concatLines;

  quoteJustString = value: "'${lib.replaceStrings [ "\\" "'" ] [ "\\\\" "\\'" ] value}'";

  renderAttribute =
    name: value:
    if value == false then
      null
    else if builtins.elem name noValueAttributes then
      if value == true then "[${name}]" else throw "Just attribute `${name}` must be boolean"
    else if name == "group" then
      "[group(${quoteJustString value})]"
    else if name == "extension" then
      "[extension(${quoteJustString value})]"
    else if name == "working-directory" then
      "[working-directory(${quoteJustString value})]"
    else
      throw "Unsupported Just attribute `${name}`";

  noValueAttributes = [
    "confirm"
    "linux"
    "macos"
    "no-cd"
    "no-exit-message"
    "positional-arguments"
    "private"
    "script"
    "unix"
    "windows"
  ];

  renderAttributes =
    attributes:
    attributes
    |> lib.mapAttrsToList renderAttribute
    |> lib.filter (line: line != null)
    |> concatLines;

  renderArg = arg: arg.name + lib.optionalString (arg.default != null) "=${arg.default}";

  renderForwardedArg = arg: "{{quote(${arg.name})}}";
in
rec {
  supportedAttributes = noValueAttributes ++ [
    "extension"
    "group"
    "working-directory"
  ];

  renderRecipe =
    name: recipe:
    let
      attrs = renderAttributes recipe.attributes;
      description = lib.optionalString (recipe.description != null) "# ${recipe.description}";
      signature = "${name}${
        lib.optionalString (recipe.args != [ ]) " ${lib.concatMapStringsSep " " renderArg recipe.args}"
      }:";
      body = indentBody recipe.text;
    in
    concatLines (
      lib.filter (line: line != "") [
        description
        attrs
        signature
        body
      ]
    );

  renderNixRunRecipe =
    name: recipe:
    renderRecipe name (
      recipe
      // {
        text =
          "nix run .#just-${name}"
          +
            lib.optionalString (recipe.args != [ ])
              " -- ${lib.concatMapStringsSep " " renderForwardedArg recipe.args}";
      }
    );

  renderJustfile =
    recipes:
    [
      "# DO-NOT-EDIT. This file was auto-generated using github:jarvahl/just-file."
      "# Use `nix run .#write-files` to regenerate it."
      ""
    ]
    ++ (
      recipes
      |> lib.mapAttrsToList (
        name: recipe:
        if recipe.runtimeInputs == null then renderRecipe name recipe else renderNixRunRecipe name recipe
      )
    )
    |> concatLines;
}
