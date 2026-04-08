{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "mirage-proxy";
  version = "unstable-2026-04-08";

  src = fetchFromGitHub {
    owner = "omdv";
    repo = "mirage-proxy";
    rev = "5fa96f72c5dd93cd83aaf57c416badb7cd7149a5";
    hash = "sha256-rr+mxtd022NiHuZsyK26l8AqHMtQQH3bB8TbJzted+k=";
  };

  cargoHash = "sha256-ZyhD4YEjzUiviJym/c+ILPln96QjBQQe+HpPr7kd4OM=";

  meta = with lib; {
    description = "Invisible sensitive data filter for LLM APIs";
    homepage = "https://github.com/omdv/mirage-proxy";
    license = licenses.mit;
    mainProgram = "mirage-proxy";
    platforms = platforms.linux;
  };
}
