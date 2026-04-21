{
  description = "Rust development template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        cargo
        rustc
        rust-analyzer
        rustfmt
        clippy
      ];

      # Set RUST_SRC_PATH so rust-analyzer can find standard library source
      RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;

      shellHook = ''
        echo "Rust $(rustc --version) | Cargo $(cargo --version)"
      '';
    };
  };
}
