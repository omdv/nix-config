{
  description = "Node.js development template with pnpm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSystem = nixpkgs.lib.genAttrs systems;
  in {
    devShells = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_20
          nodePackages.pnpm
          typescript-language-server
        ];

        shellHook = ''
          if [ -f "pnpm-lock.yaml" ]; then
            echo "Syncing Node dependencies..."
            pnpm install
          fi

          echo "Node $(node -v) | pnpm $(pnpm -v)"
        '';
      };
    });
  };
}
