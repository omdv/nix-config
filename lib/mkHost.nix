# Factory for NixOS host configurations
{ lib, inputs, outputs }:
name: lib.nixosSystem {
  modules = [ ../hosts/${name} ];
  specialArgs = { inherit inputs outputs; };
}
