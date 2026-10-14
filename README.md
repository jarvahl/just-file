# just-file

Generate a real `Justfile` from Nix.

`just-file` is a small flake-parts module. It exposes top-level `just.recipes`, renders Just syntax, and uses `mightyiam/files` to write and check a Git-trackable `Justfile`.

## Use

```nix
{
  inputs.just-file.url = "github:jarvahl/just-file";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.just-file.flakeModules.default ];

      just.recipes.check = "nix flake check";
    };
}
```

Write and validate the generated file:

```sh
nix run .#write-files
nix flake check
```

## Recipes

String recipes are shorthand for `text`:

```nix
{
  just.recipes.check = "nix flake check";
}
```

Structured recipes support descriptions, ordered arguments, native Just attributes, runtime inputs, and body text:

```nix
{ lib, ... }:
{
  just.recipes =
    (lib.genAttrs [ "build" "switch" "boot" ] (action: {
      description = "NixOS ${action}";
      args = [
        {
          name = "host";
          default = "`hostname`";
        }
      ];
      text = ''
        nixos-rebuild ${action} --flake ".#{{host}}"
      '';
    }))
    // {
      check = {
        description = "Validate flake";
        text = "nix flake check";
      };

      default = "just --list";
    };
}
```

Generated `Justfile`:

```just
# NixOS boot
boot host=`hostname`:
    nixos-rebuild boot --flake ".#{{host}}"
# NixOS build
build host=`hostname`:
    nixos-rebuild build --flake ".#{{host}}"
# Validate flake
check:
    nix flake check
default:
    just --list
# NixOS switch
switch host=`hostname`:
    nixos-rebuild switch --flake ".#{{host}}"
```

Recipe ordering is deterministic: recipes are rendered by attribute name.

## Arguments

Arguments are ordered by list position:

```nix
{
  just.recipes.deploy = {
    args = [
      { name = "target"; }
      {
        name = "mode";
        default = "'safe'";
      }
    ];
    text = "deploy {{target}} --mode {{mode}}";
  };
}
```

`default` is raw Just syntax. Use Just's own defaults and interpolation; `just-file` does not add a second expression language.

## Attributes

Native Just recipe attributes are declared as an attrset:

```nix
{
  just.recipes.deploy = {
    description = "Deploy configuration";
    args = [ { name = "target"; } ];
    attributes = {
      confirm = true;
      group = "deployment";
    };
    text = "deploy {{target}}";
  };
}
```

Generated:

```just
# Deploy configuration
[group('deployment')]
[confirm]
deploy target:
    deploy {{target}}
```

Supported attributes are validated against Just syntax: `confirm`, `extension`, `group`, `linux`, `macos`, `no-cd`, `no-exit-message`, `positional-arguments`, `private`, `script`, `unix`, `windows`, and `working-directory`.

Just requires attributes to be adjacent to the recipe signature, so descriptions render before attributes. `quiet` is not a Just recipe attribute in current Just releases; use `@` in recipe commands or a Just setting outside this initial API when needed.

## Nix-backed recipes

A recipe with `runtimeInputs` gets a per-system flake app named `just-<recipe>`.
The generated `Justfile` invokes that app through `nix run`, so no Nix store paths are written to the repository.

```nix
{
  just.recipes.format = {
    description = "Format Nix files";
    runtimeInputs = { pkgs }: [ pkgs.nixfmt ];
    text = ''
      nixfmt .
    '';
  };
}
```

Generated:

```just
# Format Nix files
format:
    nix run .#just-format
```

Arguments are forwarded with Just's `quote()` function to preserve shell argument boundaries:

```nix
{
  just.recipes.capture = {
    args = [ { name = "value"; } ];
    runtimeInputs = { pkgs }: [ pkgs.coreutils ];
    text = ''
      printf '%s\n' '{{value}}'
    '';
  };
}
```

Generated:

```just
capture value:
    nix run .#just-capture -- {{quote(value)}}
```

The app runs the recipe body through `just` internally, so Just interpolation such as `{{value}}` still works inside Nix-backed recipes.

## nix-config-style example

This preserves the behavior of the `build`, `switch`, `boot`, and `default` recipes from `jarvahl/nix-config` without copying host-specific logic into `just-file`:

```nix
{ lib, ... }:
{
  just.recipes =
    lib.genAttrs [ "build" "switch" "boot" ] (action: {
      description =
        {
          build = "[build] Build configuration for host";
          switch = "[switch] Apply configuration to host";
          boot = "[boot] Schedule configuration for next boot";
        }
        .${action};
      attributes.no-exit-message = true;
      args = [
        {
          name = "host";
          default = "host";
        }
      ];
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        nixos-rebuild ${action} \
            --flake ".#{{host}}" \
            -L \
            --accept-flake-config
      '';
    })
    // {
      default = "just --list";
    };
}
```

If you need `set quiet := true` or top-level Just variables such as `host := \`hostname\``, keep them in a hand-written wrapper or add that option when it is actually needed. The initial API intentionally only models recipes.
