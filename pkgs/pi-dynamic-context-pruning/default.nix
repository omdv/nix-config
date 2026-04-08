{
  stdenv,
  fetchurl,
}: let
  jsonc-parser = fetchurl {
    url = "https://registry.npmjs.org/jsonc-parser/-/jsonc-parser-3.3.1.tgz";
    sha256 = "4a0315b8671e7463bae7af7c142cdf19e9aa7ba39eb36dc2df383b8648e3cbc9";
  };
in
  stdenv.mkDerivation rec {
    pname = "pi-dynamic-context-pruning";
    version = "1.0.5";

    src = fetchurl {
      url = "https://registry.npmjs.org/@complexthings/pi-dynamic-context-pruning/-/pi-dynamic-context-pruning-${version}.tgz";
      sha256 = "a29da9d926cf4a8b97d1f6339e7d05306f2423f86c0eae98b1268fab88de0d04";
    };

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = ''
      tar xzf $src --strip-components=1
      mkdir -p node_modules/jsonc-parser
      tar xzf ${jsonc-parser} -C node_modules/jsonc-parser --strip-components=1
    '';

    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';

    meta = {
      description = "PI coding agent extension — Dynamic Context Pruning (DCP)";
      homepage = "https://github.com/complexthings/pi-dynamic-context-pruning";
    };
  }
