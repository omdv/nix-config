{
  stdenv,
  fetchurl,
  lib,
}: let
  jiti = fetchurl {
    url = "https://registry.npmjs.org/jiti/-/jiti-2.6.1.tgz";
    sha256 = "7984fc7841de02c0b2992a72e2069d4b569d23e58d097f9b050ea13b781fd5f1";
  };
  yaml = fetchurl {
    url = "https://registry.npmjs.org/yaml/-/yaml-2.8.3.tgz";
    sha256 = "9539805d7447def2bed5c5b4acacc283362c5e80abc5d93472b2f35f0cbf85ad";
  };
in
  stdenv.mkDerivation rec {
    pname = "taskplane";
    version = "0.24.31";

    src = fetchurl {
      url = "https://registry.npmjs.org/taskplane/-/taskplane-${version}.tgz";
      sha256 = "cda3b27d62ca3bac171c58c814887b7ec215e0ac3d4fe0b76d8e7e83a4f7704d";
    };

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = ''
      tar xzf $src --strip-components=1
      mkdir -p node_modules/jiti node_modules/yaml
      tar xzf ${jiti} -C node_modules/jiti --strip-components=1
      tar xzf ${yaml} -C node_modules/yaml --strip-components=1
    '';

    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';

    meta = {
      description = "AI agent orchestration for pi — parallel task execution with checkpoint discipline";
      homepage = "https://github.com/HenryLach/taskplane";
    };
  }
