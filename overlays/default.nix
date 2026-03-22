{inputs, ...}:
# Overlay definitions - applied in order: flake-inputs → unstable → additions → modifications
#
# Where these are applied:
#   • NixOS hosts:    via hosts/common/global/default.nix (nixpkgs.overlays)
#   • home-manager:   via home/om/nixpkgs.nix (overlays)
#   • Flake outputs:  NOT applied by default (see flake.nix flakeOutputOverlays)
{
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
        allowUnfreePredicate = _: true;
      };
    };
  };

  # Adds custom packages from pkgs/ directory
  additions = final: prev: import ../pkgs {pkgs = final;};

  # Modify/override existing nixpkgs packages here (currently empty)
  # Example: firefox = prev.firefox.override { enableWayland = true; };
  modifications = final: prev: {};
}
