{ autoPatchelfHook, fetchurl, fontconfig, glibc, stdenv }:

stdenv.mkDerivation rec {
  pname = "princexml";
  version = "15.2";
  src = fetchurl {
    url = "https://www.princexml.com/download/prince-${version}-linux-generic-x86_64.tar.gz";
    hash = "sha256-EMc/m8GZJNa6DgRZ0X0jJS6oNOitmSz0g6SfrvHpz7o=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    fontconfig
    glibc
  ];

  installPhase = ''
    ./install.sh $out
    ln -sf /var/lib/prince/license.dat $out/lib/prince/license/license.dat
  '';
}