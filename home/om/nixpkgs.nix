# This file should be included when using hm standalone
{outputs, ...}: {
  nixpkgs = {
    overlays = outputs.lib.orderedOverlays;
    config = {
      allowUnfree = true;
    };
  };
}
