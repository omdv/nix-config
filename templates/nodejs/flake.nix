{
  description = "Node.js development shell with pnpm";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nodejs_22
        pnpm
        typescript
        typescript-language-server
      ];

      shellHook = ''
        echo "Node $(node -v) | pnpm $(pnpm -v)"
        if [ -f "pnpm-lock.yaml" ]; then
          echo "Installing dependencies (pnpm install)..."
          pnpm install
        fi
      '';
    };
  };
}
