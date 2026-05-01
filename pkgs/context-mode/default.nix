{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
  bun,
}:
buildNpmPackage rec {
  pname = "context-mode";
  version = "1.0.103";

  src = fetchurl {
    url = "https://registry.npmjs.org/context-mode/-/context-mode-${version}.tgz";
    hash = "sha256-/oKIXsc2YL8uxhp6G9pK4+Jj5jzmjkP04/S/Y3ER1hU=";
  };

  sourceRoot = "package";

  npmDepsHash = "sha256-6ekYzKPJUZwVJL30t6ZvMTgthyL+KODf98uI7QdDdCY=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmFlags = [ "--legacy-peer-deps" ];
  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/context-mode
    cp -r . $out/lib/node_modules/context-mode/

    mkdir -p $out/bin
    cat > $out/bin/context-mode <<EOF
#!/bin/sh
export PATH="${bun}/bin:$PATH"
exec ${nodejs_22}/bin/node $out/lib/node_modules/context-mode/cli.bundle.mjs "$@"
EOF
    chmod +x $out/bin/context-mode

    runHook postInstall
  '';

  meta = {
    description = "Context Mode CLI";
    mainProgram = "context-mode";
  };
}