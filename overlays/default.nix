{ inputs, ... }: {

  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
          packages = (flake.packages or {}).${final.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else packages
      )
      inputs;
  };

  # Adds pkgs.unstable == inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}
  unstable = final: _: {
    unstable = inputs.nixpkgs-unstable.legacyPackages.${final.system};
  };

  # Adds custom packages here
  additions = final: prev: import ../pkgs {pkgs = final;};

  # Add custom modifications here
  modifications = final: prev: {};
}
