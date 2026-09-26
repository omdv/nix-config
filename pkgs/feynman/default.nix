{
  stdenv,
  fetchurl,
  lib,
  patchelf,
}: let
  pname = "feynman";
  version = "0.5.5";

  sources = {
    x86_64-linux = {
      url = "https://github.com/Companion-Inc/feynman/releases/download/v${version}/feynman-${version}-linux-x64.tar.gz";
      hash = "sha256-us6nvxpoQjosMSMxefAvhbEaUtVEePeaL2lyjtZpbOA=";
    };
    aarch64-linux = {
      url = "https://github.com/Companion-Inc/feynman/releases/download/v${version}/feynman-${version}-linux-arm64.tar.gz";
      hash = "sha256-22WVuYIoTKC9bGxpT10YMSE/S7CIKDWu6xpYzbdFmiU=";
    };
  };

  src = fetchurl (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}"));
in
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [patchelf];

    dontBuild = true;
    dontPatchELF = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/feynman $out/bin
      cp -R ./* $out/share/feynman/
      cat >$out/bin/feynman <<EOF
      #!${stdenv.shell}
      exec $out/share/feynman/feynman "\$@"
      EOF
      chmod 0755 $out/bin/feynman

      # Patch the bundled Node binary directly, matching the oh-my-pi
      # self-contained bundle pattern instead of using autoPatchelfHook.
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${lib.makeLibraryPath [stdenv.cc.cc.lib stdenv.cc.cc.libgcc]}" \
          $out/share/feynman/node/bin/node
      ''}

      runHook postInstall
    '';

    meta = {
      description = "Open source AI research agent";
      homepage = "https://github.com/Companion-Inc/feynman";
      license = lib.licenses.mit;
      maintainers = [];
      platforms = builtins.attrNames sources;
      mainProgram = "feynman";
    };
  }
