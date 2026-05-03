{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "mirage-proxy";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "omdv";
    repo = "mirage-proxy";
    rev = "v0.1.0";
    hash = "sha256-oOxEnt3AwIgB1gFTMSHVigx23h1Wx/rahT3g7wDUZ30=";
  };

  cargoHash = "sha256-fTigHEyp1vydUWUaJyvuFxyUuVumVJluwzg0k7omI0o=";

  meta = with lib; {
    description = "Invisible sensitive data filter for LLM APIs";
    homepage = "https://github.com/omdv/mirage-proxy";
    license = licenses.mit;
    mainProgram = "mirage-proxy";
    platforms = platforms.linux;
  };
}
