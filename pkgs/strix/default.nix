{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  zlib,
}: let
  pname = "strix";
  version = "1.7.1";
  target = "linux-x86_64";
  archiveName = "${pname}-${version}-${target}";
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/usestrix/strix/releases/download/v${version}/${archiveName}.tar.gz";
      hash = "sha256-yOg2JRV4uqIor+nmX0qQHvauERbERPjwpn9654mMSA8=";
    };

    sourceRoot = ".";
    dontBuild = true;

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [zlib];

    installPhase = ''
      runHook preInstall

      install -D -m755 ${archiveName} $out/bin/strix

      runHook postInstall
    '';

    meta = {
      description = "Open-source AI penetration testing agent";
      homepage = "https://github.com/usestrix/strix";
      license = lib.licenses.asl20;
      maintainers = [];
      platforms = ["x86_64-linux"];
      mainProgram = "strix";
    };
  }
