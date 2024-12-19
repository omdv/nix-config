{
  description = "My NixOS configuration";

  inputs = {
    # Nix ecosystem
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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

    # Third party programs, packaged with nix
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    systems,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
    );
  in {
    inherit lib;
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    overlays = import ./overlays {inherit inputs outputs;};
    hydraJobs = import ./hydra.nix {inherit inputs outputs;};

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});
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
    };

    nixosConfigurations = {
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
        modules = [
          ./home/om/framework.nix
          ./home/om/nixpkgs.nix
        ];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
          colors = inputs.nix-colors;
        };
      };
    };

    homeConfigurations = {
      "om@homelab" = lib.homeManagerConfiguration {
        modules = [
          ./home/om/homelab.nix
          ./home/om/nixpkgs.nix
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
