{ stdenv
, fetchurl
, lib
, patchelf
}:

let
  pname = "oh-my-pi";
  version = "13.3.6";

  # Platform-specific download URLs
  sources = {
    x86_64-linux = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-x64";
      hash = "sha256-lMZ/LlLE36CLiiwG90Yfsf/sFRJGWjTxNoWyMI8y4Hw=";
    };
    aarch64-linux = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-linux-arm64";
      hash = lib.fakeHash;
    };
    x86_64-darwin = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-x64";
      hash = lib.fakeHash;
    };
    aarch64-darwin = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${version}/omp-darwin-arm64";
      hash = lib.fakeHash;
    };
  };

  src = fetchurl (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}"));

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ patchelf ];

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
    maintainers = [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "omp";
  };
}
