{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "mirage-proxy";
  version = "unstable-2026-04-06";

  src = fetchFromGitHub {
    owner = "omdv";
    repo = "mirage-proxy";
    rev = "2a9ed52c5db86af59c4d4a3c2ff2879eb085e906";
    hash = "sha256-NRkphq3xk0O9CSvFLpq6vr4d+cz1DxQS4CSOIgU4iXA=";
  };

  cargoHash = "sha256-EjS+Qj3fvp9O/EJH2b+3eKUPlV4JqVDul/4p7js1NfU=";

  meta = with lib; {
    description = "Invisible sensitive data filter for LLM APIs";
    homepage = "https://github.com/omdv/mirage-proxy";
    license = licenses.mit;
    mainProgram = "mirage-proxy";
    platforms = platforms.linux;
  };
}
