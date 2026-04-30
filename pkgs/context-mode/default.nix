{ stdenvNoCC, nodejs_22 }:
stdenvNoCC.mkDerivation {
  pname = "context-mode";
  version = "latest";

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    export HOME="$TMPDIR"
    mkdir -p "$out"
    ${nodejs_22}/bin/npm install -g context-mode --prefix "$out"

    runHook postInstall
  '';
}
