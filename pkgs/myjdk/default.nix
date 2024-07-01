{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  pname = "myjdk";
  version = "22";

  src = fetchurl {
    url = "https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.tar.gz";
    sha256 = "uxppla5joERWsfCPrnCnG+WfweNQwnSKJS6HsHvBw24=";
  };

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';

  meta = with lib; {
    description = "My custom Java JDK";
    platforms = platforms.all;
  };
}
