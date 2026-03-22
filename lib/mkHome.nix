# Factory for Home Manager configurations
{
  lib,
  inputs,
  outputs,
  pkgsFor,
}: name: host:
lib.homeManagerConfiguration {
  pkgs = pkgsFor.x86_64-linux;
  modules = [
    ../home/${name}/${host}.nix
    ../home/${name}/nixpkgs.nix
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-colors.homeManagerModules.default
  ];
  extraSpecialArgs = {
    inherit inputs outputs;
    # Note: lib is NOT passed here - modules get HM-extended lib automatically
    mkSecret = import ./mkSecret.nix {inherit lib;};
    colors = inputs.nix-colors;
  };
}
