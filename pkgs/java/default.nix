{ stdenv, lib, fetchurl, unzip }:

stdenv.mkDerivation rec {
  pname = "myjdk";
  version = "22";

  src = fetchurl {
    url = "https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.tar.gz";

  buildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out
    cp -R * $out
  '';

  meta = with lib; {
    description = "My custom Java JDK";
    platforms = platforms.all;
  };
}
