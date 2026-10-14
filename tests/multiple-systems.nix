{ ... }:
{
  just.recipes.tool = {
    runtimeInputs = { pkgs }: [ pkgs.coreutils ];
    text = "printf ok";
  };

  perSystem = { pkgs, ... }: {
    packages.default = pkgs.writeShellApplication {
      name = "test-multiple-systems";
      runtimeInputs = [
        pkgs.gnugrep
        pkgs.nix
      ];
      text = ''
        nix flake show --json 2>/dev/null | grep -F 'just-tool'
      '';
    };
  };
}
