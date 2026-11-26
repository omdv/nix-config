# Factory for NixOS host configurations
{
  lib,
  inputs,
  outputs,
}: hostModule:
lib.nixosSystem {
  modules = [hostModule];
  specialArgs = {
    inherit inputs outputs lib;
    mkSecret = import ./mkSecret.nix {inherit lib;};
  };
}
