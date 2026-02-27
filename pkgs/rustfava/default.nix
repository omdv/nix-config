{ appimageTools, fetchurl }:
let
  pname = "rustfava";
  version = "0.1.8";
  src = fetchurl {
    url = "https://github.com/rustledger/rustfava/releases/download/v${version}/rustfava_${version}_amd64.AppImage";
    sha256 = "00f62bfg0lp3rjhp1fyfrwnc8c534h5rca8614m691ndawny9z36";
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  meta = {
    description = "Rust implementation of Fava for Beancount";
    homepage = "https://github.com/rustledger/rustfava";
  };
}
