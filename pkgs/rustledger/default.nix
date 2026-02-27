{ stdenv, fetchurl, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "rustledger";
  version = "0.9.1";

  src = fetchurl {
    url = "https://github.com/rustledger/rustledger/releases/download/v${version}/rustledger-v${version}-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "1v4x9n7mqszmilxwkbvp1aisigkijcpikb3dr04qg15cbxavq1qm";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/bin
    cp rustledger $out/bin/
    chmod +x $out/bin/rustledger
  '';

  meta = {
    description = "Rust implementation of ledger-cli";
    homepage = "https://github.com/rustledger/rustledger";
  };
}
