{
  stdenv,
  fetchurl,
  lib,
  autoPatchelfHook,
}: let
  pname = "nono";
  version = "0.81.0";

  sources = {
    x86_64-linux = {
      url = "https://github.com/nolabs-ai/nono/releases/download/v${version}/nono-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-fswz/5w0m9+oS0SW56dVX2e8wz8eElx9+e+2U8bE5Wk=";
    };
  };

  src = fetchurl (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}"));
in
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [stdenv.cc.cc.lib];
    sourceRoot = ".";

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -D -m755 nono $out/bin/nono

      runHook postInstall
    '';

    meta = {
      description = "Sandbox any AI agent in seconds";
      homepage = "https://github.com/nolabs-ai/nono";
      license = lib.licenses.asl20;
      maintainers = [];
      platforms = ["x86_64-linux"];
      mainProgram = "nono";
    };
  }
