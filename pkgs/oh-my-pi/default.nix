{
  stdenv,
  fetchurl,
  lib,
  patchelf,
}: let
  pname = "oh-my-pi";
  version = "14.9.3";

  # Platform-specific download URLs
  sources = {
    x86_64-linux = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
      hash = "sha256-obV37jq/3JJ2FQ0/tsMIe0HiuhHt2584xBQ560pb0ag=";
    };
  };

  src = fetchurl (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}"));
in
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [patchelf];

    dontUnpack = true;
    dontBuild = true;
    dontPatchELF = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -D -m755 $src $out/bin/omp

      # Patch only the interpreter, don't use autoPatchelfHook
      # Bun-compiled binaries are self-contained and don't need library patching
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/omp
      ''}

      runHook postInstall
    '';

    meta = {
      description = "AI coding agent for the terminal - fork of pi-coding-agent with extended features";
      homepage = "https://github.com/can1357/oh-my-pi";
      license = lib.licenses.mit;
      maintainers = [];
      platforms = ["x86_64-linux"];
      mainProgram = "omp";
    };
  }
