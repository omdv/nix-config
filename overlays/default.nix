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

  # Bring all custom packages into scope
  additions = final: _prev: {
    pkgs = import ../pkgs _prev;
  };

  # Add custom modifications here
  modifications = final: prev: {
  };
}
