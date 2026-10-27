{inputs, ...}: let
  # Named exports stay available as outputs.overlays.<name>.
  named = {
    # For every flake input, aliases 'pkgs.inputs.${flake}' to
    # 'inputs.${flake}.packages.${pkgs.stdenv.hostPlatform.system}' or
    # 'inputs.${flake}.legacyPackages.${pkgs.stdenv.hostPlatform.system}'
    flake-inputs = final: _: {
      inputs =
        builtins.mapAttrs (
          _: flake: let
            legacyPackages = (flake.legacyPackages or {}).${final.stdenv.hostPlatform.system} or {};
            packages = (flake.packages or {}).${final.stdenv.hostPlatform.system} or {};
          in
            if legacyPackages != {}
            then legacyPackages
            else packages
        )
        inputs;
    };

    # Adds pkgs.unstable with allowUnfree enabled
    unstable = final: _: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
        };
      };
    };

    # Adds custom packages from pkgs/ directory
    additions = final: prev: import ../pkgs {pkgs = final;};

    # Modify/override existing nixpkgs packages here (currently empty)
    # Example: firefox = prev.firefox.override { enableWayland = true; };
    modifications = final: prev: {};
  };
in {
  inherit named;

  # Overlay definitions are precedence-sensitive; never derive this with attrValues.
  ordered = with named; [
    flake-inputs
    unstable
    additions
    modifications
  ];
}
