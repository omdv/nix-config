# This file should be included when using hm standalone
{
  outputs,
  ...
}: {
  # nix = {
  #   settings = {
  #     experimental-features = [
  #       "nix-command"
  #       "flakes"
  #       "ca-derivations"
  #     ];
  #     warn-dirty = false;
  #   };
  # };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}
