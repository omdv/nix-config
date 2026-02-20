{
  description = "My NixOS configuration";

  inputs = {
    # Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gl = {
      url = "github:nix-community/nixgl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    systems.url = "github:nix-systems/default-linux";
    hardware.url = "github:nixos/nixos-hardware";
    flake-utils.url = "github:numtide/flake-utils";

    # Third party programs, packaged with nix
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nix-colors.url = "github:misterio77/nix-colors";
    micasa.url = "github:cpcloud/micasa";

    # Claude Desktop flake
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      systems,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;

      # Function to create a pkgs set with specific overlays for a given system
      mkPkgsWithOverlays =
        system: overlays:
        import nixpkgs {
          inherit system;
          inherit overlays;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
        };

      # Define common overlays that Home Manager might want to use
      homeManagerCommonOverlays = [
      ];

      # pkgsFor is for general package building across different systems.
      # It *should* also apply overlays if you expect your 'packages' or 'devShells'
      # to use the overlaid versions. If not, remove homeManagerCommonOverlays here.
      forEachSystem =
        f: lib.genAttrs (import systems) (system: f (mkPkgsWithOverlays system homeManagerCommonOverlays));
      pkgsFor = lib.genAttrs (import systems) (
        system: mkPkgsWithOverlays system homeManagerCommonOverlays
      );
    in
    {
      inherit lib;
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      overlays = import ./overlays { inherit inputs outputs; };
      hydraJobs = import ./hydra.nix { inherit inputs outputs; };

      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachSystem (pkgs: import ./shell.nix { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.alejandra);

      # Host configurations
      nixosConfigurations = {
        framework = lib.nixosSystem {
          modules = [
            ./hosts/framework
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
        homelab = lib.nixosSystem {
          modules = [
            ./hosts/homelab
          ];
          specialArgs = {
            inherit inputs outputs;
          };
        };
      };

      # Home configurations
      homeConfigurations = {
        "om@framework" = lib.homeManagerConfiguration {
          pkgs = mkPkgsWithOverlays "x86_64-linux" homeManagerCommonOverlays;
          modules = [
            ./home/om/framework.nix
            ./home/om/nixpkgs.nix
            inputs.sops-nix.homeManagerModules.sops
            inputs.nix-colors.homeManagerModules.default
          ];
          extraSpecialArgs = {
            inherit inputs outputs;
            colors = inputs.nix-colors;
          };
        };
        "om@homelab" = lib.homeManagerConfiguration {
          modules = [
            ./home/om/homelab.nix
            ./home/om/nixpkgs.nix
            inputs.sops-nix.homeManagerModules.sops
            inputs.nix-colors.homeManagerModules.default
          ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs outputs;
            colors = inputs.nix-colors;
          };
        };
      };
    };
}
